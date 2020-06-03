
;; TODO: 用yasnipat来放多个参数来作为模板
(defun dl/q ()
  (interactive)
  (insert "
(d/q '[:find
       :where ]
      db)
")
  )

(provide 'jim-datalog)
