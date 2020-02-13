(defun ess-eval-sexp (vis)
  (interactive "P")
  (save-excursion
    (backward-sexp)
    (let ((end (point)))
      (forward-sexp)
      (ess-eval-region (point) end vis "Eval sexp"))))

(add-hook 'ess-mode-hook (lambda () (define-key global-map (kbd "C-x C-e") 'ess-eval-sexp) ))

(provide 'jim-r-lisp)
