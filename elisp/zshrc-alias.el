;; 在mutil-term下面不需要这个补全,不然会导致zsh的补齐不了
;; (eval-after-load
;;     'company-mode
;;   (progn
;;     (define-key company-mode-map (kbd "<tab>")
;;       'company-indent-or-complete-common)
;;     (define-key company-mode-map (kbd "TAB")
;;       'company-indent-or-complete-common)))
;; 补全列表的中文错位问题
;; (company-posframe-mode 1)
;; C-c C-c执行顶级表达式:忽略掉( comment (+ 1 2))

(defun is-scratch? ()
  (string= "/" default-directory))

(defun switch-to-git-projects (op-fn)
  (ivy-read "Switch to git project:"
            (projectile-relevant-known-projects)
            :action
            (lambda (project)
              (message (format "Switched in git project: %s"   project))
              (funcall op-fn project))))

(defun cag ()
  (interactive)
  (call-interactively #'counsel-projectile-ag))

(defun e-c ()
  (interactive)
  (cider-pprint-eval-last-sexp-to-comment))

;; 在Emacs启动的mutil-term是zsh # 在外面终端启动的是closh
(defun zsh ()
  "TODO: 直接输入命令作为zsh tab名字,否则就输入ls"
  (interactive)
  (let* ((buffer-name
          (format "%s"
                  (read-string
                   (format "zsh name %d:"
                           (random 10))))))
    (if (y-or-n-p "在当前打开目录?")
        (vterm (format "zsh-%s" buffer-name))
      (switch-to-git-projects
       (lambda (project)
         (setq default-directory project)
         (vterm (format "zsh-%s" buffer-name)))))))

;; 定时做减法是整理的艺术
(defun vv ()
  (interactive)
  (find-file
   (if (null (getenv "PWD"))
       "~/.emacs.d/init.el"
     "~/emacs_spark/init.el")))

;; 做一个在终端中使用find-file: ec --eval "(find-file file)" => ef的shell函数打开文件
(defun vvv ()
  (interactive)
  (find-file "~/.zshrc"))

;; 迁移原有的配置查看
(defun v-old ()
  (interactive)
  (find-file "~/old_emacs_spark/init.el"))
(defun v-clj ()
  (interactive)
  (find-file "~/old_emacs_spark/_closhrc"))
(defun v-py ()
  (interactive)
  (find-file "~/.xonshrc"))

;; 一个项目同时连接clojure和cljs两个repl: 打开项目的一个cljs文件,然后在文件下面依次执行命令 => jack => sibl
(defun jack ()
  "1. deps.edn + shadow的前端的cider repl连接"
  (interactive)
  (push-it-real-good
   "M-x" "cider-jack-in-cljs"
   "<return>" "shadow-cljs"))
(defun sibl ()
  "2. 先要启动jack,需要在cljs:shadow的buffer下面启动才行"
  (interactive)
  (cider-connect-sibling-clj nil))

;; 同时修改多个文件的目录:
;; 1. M-x find-name-dired => 输入目录 => 输入*abc*表达式
;; 2. C-x C-q => 修改文件和文件夹的名字
;; 3. C-x C-s

;; 同时修改多个文件的某个关键词
;;### 1. projectile-grep搜索关键词
;;### 2. wgrep-change-to-wgrep-mode
;;### 3. mutil-cursors 选择多个 C->,然后修改
;;### 4. C-c C-c
;; ## 5.点击关闭Emacs就会提示你保存文件
(defun gag ()
  "1. 查询关键词的列表出来"
  (interactive)
  ;; (projectile-grep)
  ;; (projectile-ag)
  (call-interactively #'projectile-ripgrep)) ;; 交互调用一个命令
(defun gsub ()
  "2. 进入wgrep模式,多文件编辑 => M->多个关键词同时修改"
  (interactive)
  (wgrep-change-to-wgrep-mode))
(defun gsave ()
  "3. 保存多个被修改的文件"
  (interactive)
  (call-interactively #'save-some-buffers))

(defun gsub-file ()
  (interactive)
  (call-interactively #'find-name-dired))
;; M-x magit-status => #  按下修改的文件就会打印出来
;; ## git add # s
;; ### commmit # cc
;; ### C-c C-c
;; ## P ## -> u 选远程分支
;; ## F 更新 pull => u
;; ## ll # log ## tig
;; ## => tab展开文件的git log
;; ## q退出
;; ## C-g 推出终端
;; k是checkout文件
;; r u 是rebase命令,去掉中间的多余merge的commit
(defun gs (&optional project)
  (interactive)
  (let* ((switch-fn
          (lambda ()
            (switch-to-git-projects
             (lambda (project)
               (magit-status project))))))
    (if (is-scratch?)
        (funcall switch-fn)
      (if (y-or-n-p "是否git当前目录?")
          (magit-status)
        (funcall switch-fn)))))

(defun clj-pom ()
  (interactive)
  (shell-command-to-string "clojure -Spom"))

;; 暗红色
(defun red ()
  (interactive)
  (insert "\"#de171a\""))

;; 白浅银灰色
(defun gray-w ()
  (interactive)
  (insert "\"#f8f8f8\""))

(defun get-git-all-file ()
  "git ls-files会显示出来二进制文件, 此命令全部是文本文件"
  (interactive)
  (shell-command-to-string "git grep --cached -Il ''"))

(defun dblue ()
  (interactive)
  (insert "\"#5c6b74\""))

;; C-M-b #

(provide 'zshrc-alias)
