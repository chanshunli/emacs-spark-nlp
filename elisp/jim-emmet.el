(require 'emmet-mode)

;; https://github.com/smihica/emmet-mode

(use-package emmet-mode
  :hook (mhtml-mode nxml-mode css-mode)
  :bind
  (:map emmet-mode-keymap
        ("M-RET" . 'emmet-expand-line))
  :init
  (add-hook 'mhtml-mode-hook 'emmet-mode)
  (add-hook 'mhtml-mode-hook 'smartparens-mode))

(use-package xml
  :mode ("\\.wxml\\'" . mhtml-mode))

(use-package css-mode
  :mode ("\\.wxss\\'" . css-mode))

(provide 'jim-emmet)
