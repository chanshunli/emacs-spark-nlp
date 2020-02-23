(defun user/yas-load-local-snippets ()
  (interactive)
  (when (projectile-project-root)
    (let ((local-yas-dir (concat (projectile-project-root) ".yas")))
      (yas-load-directory local-yas-dir))))

;; 如果有projectile的话，这个能自动把 project root/.yas/ 里面的模板加进来
;; 比如 .yas/clojure-mode/xxx
(add-hook 'yas-minor-mode-hook #'user/yas-load-local-snippets)

(provide 'jim-yasnipet)
