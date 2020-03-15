(require 'clomacs)

(clomacs-defun postwalk-editer-set-emacs-connection
               clomacs/set-emacs-connection
               :lib-name "postwalk-editer")
(clomacs-defun postwalk-editer-close-emacs-connection
               clomacs/close-emacs-connection
               :lib-name "postwalk-editer")
(clomacs-defun postwalk-editer-require
               clojure.core/require
               :lib-name "postwalk-editer")

(comment
 (postwalk-editer-httpd-start))
(defun postwalk-editer-httpd-start ()
  "需要Clojure调用Emacs函数的时候,要先启动这个http服务"
  (interactive)
  (cl-flet ((clomacs-set-emacs-connection 'postwalk-editer-set-emacs-connection)
            (clomacs-require 'postwalk-editer-require))
    (clomacs-httpd-start)))

(defun postwalk-editer-httpd-stop ()
  (cl-flet ((clomacs-close-emacs-connection 'postwalk-editer-close-emacs-connection)
            (clomacs-require 'postwalk-editer-require))
    (clomacs-httpd-stop)))

(clomacs-defun postwalk-editer-md-to-html-wrapper
               my-md-to-html-string
               :namespace postwalk-editer.core
               :lib-name "postwalk-editer"
               :doc "Convert markdown to html via clojure lib.")

(defun postwalk-editer-mdarkdown-to-html (beg end)
  "Add to the selected markdown text it's html representation."
  (interactive "r")
  (save-excursion
    (if (< (point) (mark))
        (exchange-point-and-mark))
    (insert
     (concat "\n" (postwalk-editer-md-to-html-wrapper
                   (buffer-substring beg end))))))

(clomacs-defun postwalk-editer-strong-emacs-version
               strong-emacs-version
               :namespace postwalk-editer.core
               :lib-name "postwalk-editer"
               :doc "Get Emacs version with markdown strong marks."
               :httpd-starter 'postwalk-editer-httpd-start)

(clomacs-defun postwalk-editer-dot-word
               postwalk-editer.lmdb/dot-word
               :lib-name "postwalk-editer")

(clomacs-defun postwalk-editer-get-word-vector
               postwalk-editer.lmdb/get-word-vector
               :lib-name "postwalk-editer")

(clomacs-defun postwalk-editer-generate-project-txt8-files
               postwalk-editer.word2vec/generate-project-txt8-files
               :lib-name "postwalk-editer")

(comment
 (postwalk-editer-get-word-vector "python") ;=> 输出词向量,但是两个参数,就不知道怎么定义对接了
 (postwalk-editer-dot-word "apple" "steve") ;=> Not enough arguments for format string => 没有找到的单词才会爆的错误

 (postwalk-editer-dot-word "python" "tensorflow") ;;=> 429
 ;; 因为看它的宏,就知道: defun ,el-func-name (&rest attributes) # 参数是不确定的
 )

;; ------- TODO 用词向量来搜索排序和学习历史-----
;; 当前词向量，近义词跳转
;; 而不需要输入具体词，才能跳转
;; 用gemsin的包
;; 词向量跳转：在函数内跳转，还是在文件内跳转，还是在项目内跳转，还在在依赖以内跳转
;; 用在emacs身上，改变你的编程
;; 还有seq2seq模型生成代码注释
;; 所有搜索和排序的地方都可以用它来弄
;; 用机器学习的方法来优化用户使用体验
;; 还有可以使用专家系统来推断 ，根据历史来学习
;; 讯飞的语音输入和打字输入的多模型迁移学习训练: 如何用产品本身的力量来生成标注数据,用迁移学习训练到你不具备的映射能力呢?

(defun get-git-root ()
  "vc-root-dir的替代者,可以在clojure里面调用成功"
  (-> "git rev-parse --show-toplevel"
      shell-command-to-string
      s-trim))

(defun run-in-vc-root (op-fn)
  "提供在vc-root环境下跑的环境"
  (let* ((old default-directory)
         (-tmp  (setq default-directory (get-git-root))))
    (let*  ((res (funcall op-fn)))
      (progn
        (setq default-directory old)
        res))))

(comment
 (get-vc-all-git-files))

(defun get-vc-all-git-files ()
  "可以输出git想要的非banery的文件列表"
  (run-in-vc-root
   (lambda ()
     (shell-command-to-string "git grep --cached -Il ''"))))

(defun vc-text-file-name ()
  "word2vec训练需要的文本语料库,每个项目最多需要生成一个"
  (format
   "%s.text8"
   (nth 0 (reverse (split-string (get-git-root) "/")))))

(defun word2vec-training ()
  (let* ((text8-file (postwalk-editer-generate-project-txt8-files))
         (bin-file-name (replace-regexp-in-string ".text8" ".bin" text8-file))
         (cmd-list
          (list  "/Users/clojure/CppPro/word2vec/bin/word2vec"
                 "-train" text8-file
                 "-output" bin-file-name
                 "-cbow" "1" "-size" "200" "-window" "8" "-negative" "25" "-hs" "0" "-sample" "1e-4" "-threads" "20" "-binary" "1" "-iter" "15"))
         (cmd-stri
          (lambda (lis)
            (s-join " " lis))))
    (message "执行命令: %s" (funcall cmd-stri cmd-list))
    (make-process
     :name "training the word2vec file"
     :command cmd-list
     :sentinel (lambda (proc event)
                 (message "finished training the word2vec file!"))
     :buffer "*word2vec # training the word2vec file*")))

(provide 'postwalk-editer)
