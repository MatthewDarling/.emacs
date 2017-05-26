;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Stuff other people should use
;;; Allow Mac-ish frame switching
(defun other-frame-or-window ()
  (interactive)
  (let ((frame-count (length (frame-list))))
    (if (= 1 frame-count)
        (other-window 1)
      (other-frame 1))))

(global-set-key (kbd "C-`") 'other-frame-or-window)

(setq nrepl-hide-special-buffers +1 ; Hide those silly starred nrepl buffers
      cider-repl-result-prefix ";; => " ; Results in Cider REPL should be commented out
      desktop-restore-eager 3 ; Modifies desktop.el to lazily load all but the 3 most recent buffers
      load-prefer-newer t ; If there's a newer version of a compiled file, load it
      save-interprogram-paste-before-kill t) ; Save OS clipboard contents into Emacs paste history

;;; Allow narrow-to-region to be used
(put 'narrow-to-region 'disabled nil)
;;; Remove surprising behaviour of Paredit, so it obeys delete-selection-mode
;; Courtesy of Magnar Sveen: https://github.com/magnars/.emacs.d/blob/master/setup-paredit.el#L73
(put 'paredit-forward-delete 'delete-selection 'supersede)
(put 'paredit-backward-delete 'delete-selection 'supersede)
(put 'paredit-newline 'delete-selection t)

;;; Turn off whitespace-mode in the Cider REPL
(remove-hook 'cider-repl-mode-hook 'whitespace-mode)
;;; Easier access to Clojure documentation
(define-key clojure-mode-map (kbd "C-c d") 'cider-doc)
(define-key cider-repl-mode-map (kbd "C-c d") 'cider-doc)

;;; Make Org mode + Clojure awesome
;; Though one issue is that you will need to have your Org document
;; within an existing Leiningen project :(
(require 'ob-clojure) ; Org babel + clojure
;;; NOTE THAT THE CURRENT VERSION OF ORG SHIPS WITH A TERRIBLE AND OLD VERSION
;;; Manually install this file instead: http://orgmode.org/cgit.cgi/org-mode.git/plain/lisp/ob-clojure.el
;;; This guide is good once you're set up: http://orgmode.org/cgit.cgi/org-mode.git/plain/lisp/ob-clojure.el
(setq org-babel-clojure-backend 'cider
      org-confirm-babel-evaluate nil
      org-src-fontify-natively t
      org-src-preserve-indentation t)
(org-babel-do-load-languages 'org-babel-load-languages '((emacs-lisp . t)
                                                         (clojure . t)
                                                         (sh . t)))

;;; Also Emacs 25 still uses a very old Org mode, so this is necessary
(when (not (fboundp 'org-babel--get-vars))
  (defun org-babel--get-vars (params)
    "Return the babel variable assignments in PARAMS.

   PARAMS is a quasi-alist of header args, whcih may contain
   multiple entries for the key `:var'.  This function returns a
   list of the cdr of all the `:var' entries."
    (mapcar #'cdr
            (org-remove-if (lambda (x) (not (eq (car x) :var))) params))))

;;; Add special Clojure mode easy template
(add-to-list 'org-structure-template-alist
             '("clj" "#+BEGIN_SRC clojure :results output code\n?\n#+END_SRC"))

(defun exec-next-code-block ()
  "Search for the next Org mode code block, and execute it"
  (interactive)
  (when (search-forward "#+BEGIN_SRC clojure :results" nil t)
    (next-line))
  (org-ctrl-c-ctrl-c))

(defun exec-next-plus-jump-to-result ()
  (interactive)
  (exec-next-code-block)
  (search-forward "#+RESULTS:")
  (recenter-top-bottom 0))

;;; Do presentations in Org Mode
(use-package org-present :ensure t
  :init (setq org-present-text-scale 3)
  :config (progn
            (add-hook 'org-present-mode-hook
                      (lambda ()
                        (org-present-big)
                        (org-display-inline-images)
                        (global-hl-line-mode -1)
                        (annoying-arrows-mode -1)))
            (add-hook 'org-present-mode-quit-hook
                      (lambda ()
                        (org-present-small)
                        (org-remove-inline-images)
                        (global-hl-line-mode)
                        (annoying-arrows-mode))))
  :bind (:map org-present-mode-keymap
              ("C-c C-c" . exec-next-code-block)))

;;; Non-standard packages that should be standard
(use-package visual-regexp :ensure t)
(use-package visual-regexp-steroids :ensure t)

(use-package git-link :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;temporarily broken thing
;;editing-setup.el make it linum-mode +1 before goto-line, not linum-mode 1
;;(setq git-gutter-fr:side 'right-fringe)
;;(set-fringe-mode '(10 . 10))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Things other people might not like
;;; Set up modifier keys to match Windows for the Truly Ergonomic Keyboard
(setq ns-control-modifier 'meta
      ns-alternate-modifier 'meta
      ns-command-modifier 'control)

;;; Limit depth of rainbow-delimiters, it's too subtle to provide
;;; quick information and I'd rather have well-indented code to show
;;; me the nesting
(setq rainbow-delimiters-max-face-count 1)

;;; Get stuff from Marmalade when needed
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

;;; Actually kind of useful on a Mac, doesn't consume any vertical space
(menu-bar-mode +1)

;;; But these things only show the absolute basics, not useful if you know Emacs
(define-key global-map [menu-bar file] nil)
(define-key global-map [menu-bar edit] nil)
(define-key global-map [menu-bar help-menu] nil)

;;; Well, I like visible line numbers
(use-package nlinum :ensure t
  :init (require 'linum)
  :config (progn
            (defun nlinum--setup-window ()
              (set-window-margins nil nlinum--width))
            (set-face-attribute 'linum nil :underline nil :overline nil
                                :italic nil :bold nil)
            (global-nlinum-mode 1)))



;;; Make Emacs automatically adjust font size based on resolution
(defun fontify-frame (&optional frame)
  "Based on the size of a frame, set the size of its default font.

A frame height or width of more than 2000 pixels earns a size 19 font,
otherwise it's size 16.

Note that font heights are 10x what a word processor would call the font size."
  (interactive)
  (when window-system
    (let ((target (or frame (window-frame))))
      (set-face-attribute 'default
                          target
                          :height
                          (if (or (> (frame-pixel-height target) 2000)
                                  (> (frame-pixel-width target) 2000))
                              190
                            160)))))

;;; Fontify current frame for startup
(fontify-frame)
;;; Fontify new frames that are created
(add-to-list 'after-make-frame-functions 'fontify-frame)

;;; Niche packages + their setup
(use-package hideshowvis :ensure t
  ;;Puts a plus/minus symbol in the fringe for things you can fold (hide)
  :init (add-hook 'prog-mode-hook 'hideshowvis-minor-mode))

(use-package ido-vertical-mode
  ;;Makes Ido vertical, making it easier to read
  :ensure t
  :config (progn (ido-vertical-mode 1)
                 (setq max-mini-window-height 0.5)))

(use-package golden-ratio
  ;;Automatically manage the size of windows, based on the golden ratio
  :ensure t
  :diminish "Au"
  :config (progn (golden-ratio-mode 1)
                 (golden-ratio-toggle-widescreen)))

(use-package ham-mode
  ;;Transparently convert HTML files into Markdown while editing them
  :ensure t
  :mode ((".*email.*"  . ham-mode)
         (".html?" . ham-mode)))

(use-package fold-dwim
  :ensure t
  :bind (("<M-tab>" . fold-dwim-toggle)
         ("H-f" . fold-dwim-hide-all)
         ("H-s" . fold-dwim-show-all)))

(use-package key-chord :ensure t
  :config (progn
            (key-chord-mode 1)
            (key-chord-define-global "§a" 'other-frame)))

(use-package kibit-helper :ensure t)

;;;From using Sticky Keys on my Windows laptop, I type C-x b too quickly
;;;...this sends me into IBuffer 75% of the time when I want Ido instead
;;;So, this resolves that problem
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-x M-b") 'list-buffers)

;;; Org mode stuff
(setq org-startup-indented t ; Indents headings and their contents automatically
      org-return-follows-link t ; Enter opens a link in my browser
      org-hide-emphasis-markers t) ; Hide markup for bold, italic, etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Defuns from the internet
;;; Allow me to make files in directories that don't exist yet
;; taken from http://superuser.com/a/132844
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

;;; Kill starred buffers when closing them, enabled by default
;; taken from http://superuser.com/a/466109
(defadvice quit-window (before quit-window-always-kill)
  "When running `quit-window', always kill the buffer."
  (ad-set-arg 0 t))
(ad-activate 'quit-window)

;;; Code to stop `prettify-symbols-mode' messing up indentation
(defun current-value-for-prettify-symbols ()
  (interactive)
  (let ((current-setting (buffer-local-value 'prettify-symbols-mode (current-buffer))))
    (message "Current setting is: %s" current-setting)))

(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun remove-prettify-symbols (orig-fun &rest args)
  "Temporarily disable prettify-symbols during `orig-fun'."
  (if (not (buffer-local-value 'prettify-symbols-mode (current-buffer)))
      (apply orig-fun args)
    (progn (prettify-symbols-mode -1)
           (apply orig-fun args)
           (prettify-symbols-mode))))
(advice-add 'clojure-indent-region :around #'remove-prettify-symbols)
;; (advice-add 'save-buffer :around #'remove-prettify-symbols)

;;; Some custom indentation to Plumatic Schema forms
;;;see here for explanation: https://github.com/clojure-emacs/clojure-mode#indentation-of-macro-forms
(put-clojure-indent 'extend-schema '(2)) ;;;has two special arguments
(put-clojure-indent 'defschema '(1)) ;;;has one special argument
(put-clojure-indent 'abstract-map-schema '(1)) ;;;has one special argument
(put-clojure-indent 'defsystem '(2 0 nil (:defn))) ;;;has three special arguments, which have no special indentation rules, and then a bunch of arguments with defn indentation

;;; Shorten the CIDER startup help banner
(defun cider-repl--help-banner ()
  "Generate the help banner."
  (substitute-command-keys
   "\n;; ======================================================================
;;
;; Here are few tips to get you started:
;;
;; * Press <\\[cider-switch-to-last-clojure-buffer]> to switch between the REPL and a Clojure file
;; * Press <\\[cider-doc]> to view the documentation for something (e.g.
;;   a var, a Java method)
;; * Enable `eldoc-mode' to display function & method signatures in the minibuffer.
;;
;; ======================================================================
"))

;;; A version of fill-paragraph that also can unfill, call on-demand
;; taken from http://ergoemacs.org/emacs/modernization_fill-paragraph.html
;;;###autoload
(defun compact-uncompact-block ()
  "Remove or add line ending chars on current paragraph.
This command is similar to a toggle of `fill-paragraph'.
When there is a text selection, act on the region."
  (interactive)
  ;; This command symbol has a property ?'stateIsCompact-p?.
  (let (currentStateIsCompact (bigFillColumnVal 4333999) (deactivate-mark nil))
    (save-excursion
      ;; Determine whether the text is currently compact.
      (setq currentStateIsCompact
            (if (eq last-command this-command)
                (get this-command 'stateIsCompact-p)
              (if (> (- (line-end-position) (line-beginning-position))
                     fill-column) t nil)))
      (if (region-active-p)
          (if currentStateIsCompact
              (fill-region (region-beginning) (region-end))
            (let ((fill-column bigFillColumnVal))
              (fill-region (region-beginning) (region-end))) )
        (if currentStateIsCompact
            (fill-paragraph nil)
          (let ((fill-column bigFillColumnVal))
            (fill-paragraph nil)) ) )
      (put this-command 'stateIsCompact-p (if currentStateIsCompact nil t)))))

;;; Combine the functionality of rename file and rename buffer
;; taken from http://emacsredux.com/blog/2013/05/04/rename-file-and-buffer/
;;;###autoload
(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;###autoload
(defun cider-eval-and-print-into-buffer (&optional buffer)
  "Make a custom handler for evaluating and printing result in `BUFFER'.

Results will be printed as a comment after the current point location."
  (nrepl-make-response-handler (or buffer (current-buffer))
                               (lambda (buffer value)
                                 (with-current-buffer buffer
                                   (insert
                                    " ;;=>"
                                    (if (derived-mode-p 'cider-clojure-interaction-mode)
                                        (format "\n%s\n" value)
                                      value))))
                               (lambda (_buffer out)
                                 (cider-emit-interactive-eval-output out))
                               (lambda (_buffer err)
                                 (cider-emit-interactive-eval-err-output err))
                               '()))

;;;###autoload
(defun my-cider-eval-last-sexp (&optional prefix)
  "Evaluate the expression preceding point and print its result.

Result will be printed in a comment after the expression."
  (interactive "P")
  (cider-interactive-eval nil
                          (cider-eval-and-print-into-buffer)
                          (cider-last-sexp 'bounds)))
