;; TODO: 通过选择多次来加载多个参数: 中间还可以放入一个列表来输入就像C-x f先输入目录(read-sting选一个目录列表?),马上就输入ag的关键词
;; 李杀: http://ergoemacs.org/emacs/elisp_idioms_prompting_input.html
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Using-Interactive.html
;; 1. read-file-name和ivy-read的实现
;; 2. C-s 需要获取当前的单词进去
;; 3. interactive加read函数帮助输入函数多参数

;; read-string
;; read-file-name
;; read-directory-name
;; read-regexp

;; --- https://oremacs.com/swiper/
;; ivy-read: (ivy-read "Test: " '("can do" "can't, sorry" "other"))

;;(require 'ido)
;;(defun my-pick-one ()
;;  "Prompt user to pick a choice from a list."
;;  (interactive)
;;  (let ((choices '("cat" "dog" "dragon" "tiger")))
;;    (message "%s" (ido-completing-read "Open bookmark:" choices ))))

;; https://github.com/abo-abo/swiper/issues/336
;; (ivy-read "Junk file: " :initial-input rel-fname
(global-set-key
 (kbd "C-s")
 (lambda ()
   (interactive)
   ;; 'word 只会默认查询单个单词 # symbol会有带-的词也查询
   (swiper (thing-at-point 'symbol))))

;; 模糊输入选择列表在mini buffer
;;(completing-read
;; "Complete a foo: "
;; '(("foobar1" 1) ("barfoo" 2) ("foobaz" 3) ("foobar2" 4))
;; nil t "fo")
;;;; (ido-completing-read "test: " '("a" "b" "c"))

(provide 'jim-ivy)
