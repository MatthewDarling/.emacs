(use-package clojure-mode
  :ensure t
  :init (progn
          (setq buffer-save-without-query t)
          (add-hook 'clojure-mode-hook
                    (lambda ()
                      (push '("partial" . ?Ƥ) prettify-symbols-alist)
                      (push '("comp" . ?ο) prettify-symbols-alist)
                      (lisp-mode-setup))))
  :config (progn
            (diminish-major-mode 'clojure-mode "Cλ")
            (bind-key "C-c C-z" nil clojure-mode-map))) ; Remove the binding for inferior-lisp-mode

(use-package clojure-mode-extra-font-locking
  :ensure t)

(use-package cider
  :ensure t
  :init (progn
          (setq nrepl-hide-special-buffers nil
                cider-repl-pop-to-buffer-on-connect nil
                cider-prompt-for-symbol nil
                nrepl-log-messages t
                cider-popup-stacktraces t
                cider-repl-popup-stacktraces t
                cider-auto-select-error-buffer t
                cider-repl-print-length 100
                cider-repl-history-file (expand-file-name "cider-history" user-emacs-directory)
                cider-repl-use-clojure-font-lock t
                cider-switch-to-repl-command 'cider-switch-to-relevant-repl-buffer)
          (add-hook 'clojure-mode-hook 'cider-mode))
  :config (progn
            (diminish-major-mode 'cider-repl-mode "Ç»")
            (add-to-list 'same-window-buffer-names "*cider*")
            (add-hook 'cider-mode-hook 'eldoc-mode)
            (add-hook 'cider-repl-mode-hook 'lisp-mode-setup)
            (add-hook 'cider-connected-hook 'cider-enable-on-existing-clojure-buffers)

            ;;; Save CIDER REPL history every 5 minutes
            ;;; The default behaviour is to only save it when the REPL
            ;;; connection is closed, which has made me sad many times
            ;;; Via https://stackoverflow.com/a/24009529/1137749
            (defvar-local cider-save-history-timer nil
              "Buffer-local timer for saving CIDER repl history periodically.")
            (defun save-this-buffer-repl-history (buf)
              "Callback function for `cider-save-history-timer'."
              (when (buffer-live-p buf)
                (with-current-buffer buf
                  (cider-repl-history-just-save))))
            (defun start-repl-save-timer ()
              "Function to hook onto `cider-repl-mode' for auto-saving the REPL history."
              (setq cider-save-history-timer
                    (run-with-timer 0
                                    300
                                    'save-this-buffer-repl-history
                                    (current-buffer))))
            (add-hook 'cider-repl-mode-hook 'start-repl-save-timer)
            (add-hook 'kill-buffer-hook
                      (lambda ()
                        (when (timerp cider-save-history-timer)
                          (cancel-timer cider-save-history-timer)))))
  :diminish " ç")

;;; highlight is required by eval-sexp-fu, but it's done wrong, so
;;; need to install it manually
(use-package highlight :ensure t)

(use-package eval-sexp-fu :ensure t
  :init (custom-set-faces '(eval-sexp-fu-flash ((t (:foreground "green4" :weight bold))))))

(use-package cider-eval-sexp-fu :ensure t)

(use-package clj-refactor
  :ensure t
  :init (add-hook 'clojure-mode-hook (lambda ()
                                       (clj-refactor-mode 1)
                                       (cljr-add-keybindings-with-prefix "C-c M-r")))
  :diminish "")

(use-package cljsbuild-mode :ensure t)

(use-package datomic-snippets :ensure t)
