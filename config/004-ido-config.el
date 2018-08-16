(use-package ido-completing-read+ :ensure t
  :config (progn
            (ido-mode 1)
            (ido-everywhere 1)
            (ido-ubiquitous-mode 1)
            (add-to-list 'ido-ignore-files "\\.DS_Store")
            (add-hook 'ido-setup-hook
                      (lambda ()
                        ;; Go straight home
                        (define-key ido-file-completion-map (kbd "~")
                          (lambda ()
                            (interactive)
                            (if (looking-back "/")
                                (insert "~/")
                              (call-interactively 'self-insert-command))))))))

(use-package flx-ido :ensure t
  :init (setq ido-use-faces nil) ; disable ido faces to see flx highlights
  :config (flx-ido-mode t))

(use-package smex :ensure t
  :init (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)
         ("C-x C-m" . smex)))
