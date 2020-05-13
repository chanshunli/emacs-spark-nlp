
;; 也可以file-exists-p + .keep 文件
(defun have-yas-path? ()
  (file-directory-p
   (concat (projectile-project-root) ".yas")))

(defun user/yas-load-local-snippets ()
  (interactive)
  (when (projectile-project-root)
    (let ((local-yas-dir (concat (projectile-project-root) ".yas")))
      (if (have-yas-path?)
          (yas-load-directory local-yas-dir)
        (message "本项目没有yasnippet模板文件")))))

;; 如果有projectile的话，这个能自动把 project root/.yas/ 里面的模板加进来, 比如 .yas/clojure-mode/xxx
(add-hook 'yas-minor-mode-hook #'user/yas-load-local-snippets)


;; TODO:
;; 1. snippets可以写在一个文件里面,然后每次启动的时候,就去生成一堆的模板文件
;; 2. 直接搜索所有的snippets的的指令的方法
;; for file in  `find ~/.emacs.d/snippets/ -name "*" `; do echo "\n###====$file=====\n"; cat $file 2>/dev/null; done

(provide 'jim-yasnipet)
