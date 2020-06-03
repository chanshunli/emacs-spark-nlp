(defun dl/init ()
  "下面中的db和conn的变量都是来源这里"
  (interactive)
  (insert
   "
[datomic.api :as d]
(d/create-database db-uri)
(def conn (d/connect db-uri))
(def db (d/db conn))
"))

;; TODO: 用yasnipat来放多个参数来作为模板
(defun dl/q ()
  (interactive)
  (insert "
(d/q '[:find
       :where ]
      db)
"))

(defun dl/pull ()
  (interactive)
  (insert
   "
(d/pull db '[*] eid)
"))

(defun dl/pull1 ()
  (interactive)
  (insert
   "
(d/pull db ' led-zeppelin)
"))

(defun dl/search ()
  "全文搜索内容命令, 填入参数去全文搜索
 就像ls,grep命令一样透明"
  (interactive)
  ;; 返回是非字符串的结构体导致会失败message出来
  (->>
   (read-string "q:")
   (format
    "(str (d/q '[:find ?entity ?name ?tx ?score
         :in $ ?search
         :where [(fulltext $ :artist/name ?search) [[?entity ?name ?tx ?score]]]]
    db \"%s\"))")
   (eval-clj-code)
   message))

;; 做编辑器的主人,所有重复性的工作全部要被自动化掉,完全自我设计 <= `要做咏春拳学的主人`哲学思想能量转化
;; 1.需要反复重复的功能: 就用emacs来自定义化掉
;; 2.避免反复切换和打断,就直接一个命令就到达了 => 就像水一样切不断, 标月指 & Lisp机大脑流的速度
;; 3. 将代码的重复和文档性的隐藏于无形的Emacs自我设计中 <= 武术的最高境界是将技术隐藏于无形,没有任何的预先动作,随时都能最快的攻防转换
(defun dl/entity ()
  "根据eid(相当于SQL表格的主键),查出所有它的属性值出来"
  (interactive)
  ;; 返回了list,需要str出来才能打印
  (let* ((code
          (format "(str (seq (d/entity (d/db conn) %s)))"
                  (read-string "eid:"))))
    (message (eval-clj-code code))))

(provide 'jim-datalog)
