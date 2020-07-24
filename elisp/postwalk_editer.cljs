(ns postwalk-editer)

(defn print-all-class-names-style []
  (let [rules
        (array-seq
          (.-cssRules (first (array-seq js/document.styleSheets))))]
    (doseq [rule rules]
      (js/console.log (str  (.-selectorText rule) " => " (.-cssText rule))))))

;; (find-class-name-style "w-1000")
;; => ".w-100 { width: 100%; }"
(defn find-class-name-style [query]
  (let [rules
        (array-seq
          (.-cssRules (first (array-seq js/document.styleSheets))))]
    (try
      (.-cssText
        (first
          (filter (fn [rule]
                    (= (str "." query)  (.-selectorText rule)))
            rules)))
      (catch :default e
        (js/console.log (str query "类名没有找到style: " e))
        ""))))

;; (get-class-names-styles "flex flex-row h3 pa3 f4 w-100x")
;; => ("display: flex;" "flex-direction: row;" "height: 4rem;" "padding: 1rem;" "font-size: 1.25rem;")
(defn get-class-names-styles [class-stri]
  (->>
    (clojure.string/split class-stri #" ")
    (map (fn [css-name]
           (clojure.string/replace
             (find-class-name-style css-name)
             #".(.*) \{ (.*) \}"
             "$2")))
    (clojure.string/join "")))
