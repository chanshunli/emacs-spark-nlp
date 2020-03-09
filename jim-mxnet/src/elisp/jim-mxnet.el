(require 'clomacs)

(clomacs-defun jim-mxnet-set-emacs-connection
               clomacs/set-emacs-connection
               :lib-name "jim-mxnet")
(clomacs-defun jim-mxnet-close-emacs-connection
               clomacs/close-emacs-connection
               :lib-name "jim-mxnet")
(clomacs-defun jim-mxnet-require
               clojure.core/require
               :lib-name "jim-mxnet")

(comment
 (jim-mxnet-httpd-start))
(defun jim-mxnet-httpd-start ()
  (cl-flet ((clomacs-set-emacs-connection 'jim-mxnet-set-emacs-connection)
            (clomacs-require 'jim-mxnet-require))
    (clomacs-httpd-start)))

(defun jim-mxnet-httpd-stop ()
  (cl-flet ((clomacs-close-emacs-connection 'jim-mxnet-close-emacs-connection)
            (clomacs-require 'jim-mxnet-require))
    (clomacs-httpd-stop)))

(clomacs-defun jim-mxnet-md-to-html-wrapper
               my-md-to-html-string
               :namespace jim-mxnet.core
               :lib-name "jim-mxnet"
               :doc "Convert markdown to html via clojure lib.")

(defun jim-mxnet-mdarkdown-to-html (beg end)
  "Add to the selected markdown text it's html representation."
  (interactive "r")
  (save-excursion
    (if (< (point) (mark))
        (exchange-point-and-mark))
    (insert
     (concat "\n" (jim-mxnet-md-to-html-wrapper
                   (buffer-substring beg end))))))

(clomacs-defun jim-mxnet-strong-emacs-version
               strong-emacs-version
               :namespace jim-mxnet.core
               :lib-name "jim-mxnet"
               :doc "Get Emacs version with markdown strong marks."
               :httpd-starter 'jim-mxnet-httpd-start)

(clomacs-defun jim-mxnet-dot-word
               jim-mxnet.tensorflow/dot-word
               :lib-name "jim-mxnet")

(clomacs-defun jim-mxnet-get-word-vector
               jim-mxnet.tensorflow/get-word-vector
               :lib-name "jim-mxnet")

(comment
 (jim-mxnet-get-word-vector "python") ;=> 输出词向量,但是两个参数,就不知道怎么定义对接了
 (jim-mxnet-dot-word "apple" "steve") ;=> Not enough arguments for format string => 没有找到的单词才会爆的错误

 (jim-mxnet-dot-word "python" "tensorflow") ;;=> 429
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

(defun run-in-vc-root (op-fn)
  "提供在vc-root环境下跑的环境"
  (let* ((old default-directory)
         (-tmp  (setq default-directory (vc-root-dir))))
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
   (nth 1 (reverse (split-string (vc-root-dir) "/")))))

(comment
 (append-to-file "xyz\n" nil "file.txt")
 )

(cl-defun ejc-complete-auto-complete (buffer-name point)
  (switch-to-buffer buffer-name)
  ;; (if (equal point (point))
  ;;     (auto-complete))
  "aaaaa")

(defun ejc-complete-auto-complete-2 (buffer-name point)
  (switch-to-buffer buffer-name)
  ;; (if (equal point (point))
  ;;     (auto-complete))
  "22222")

(provide 'jim-mxnet)
