(require 'emmet-mode)

;;(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
;;(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
;;(add-hook 'emmet-mode-hook (lambda () (setq emmet-indent-after-insert nil)))
;;(add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2))) ;; indent 2 spaces.

(use-package emmet-mode
  :hook (mhtml-mode nxml-mode)
  :bind
  (:map emmet-mode-keymap
        ("C-RET" . 'emmet-expand-line))
  :init
  (add-hook 'mhtml-mode-hook 'emmet-mode)
  (add-hook 'web-mode-hook 'emmet-mode))

(add-hook 'mhtml-mode-hook 'smartparens-mode)

(use-package xml
  :mode ("\\.wxml\\'" . web-mode))

(use-package css-mode
  :mode ("\\.wxss\\'" . css-mode))

(provide 'jim-emmet)
