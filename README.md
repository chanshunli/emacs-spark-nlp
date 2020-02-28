## Emacs 流式编辑器: EmacsSpark

*Feature*

* 运用运行时的cider来Postwalk修改代码本身(专门弄一个clojure前后端库[postwalk-editer](https://github.com/chanshunli/postwalk-editer)来支持流式编辑)
* 结合yasnippet的使用
* 记录Lisp Repl的历史,通过历史的代码来训练帮助补全代码
* 融合代码语义搜索和EmacsSpark(天天在用,无时不刻都在用的东西,才能真正的看到它的缺点,改进它)
* 流式响应编辑的速度(编辑源头的数据,所有的都变成编辑的算子去流式的编辑) VS Lispy式的快速移动选中的速度
* 所有的代码都是分布式表示存储的,可以从数据库里面快速取出来代码,合成现在你需要的代码
* 所有的代码都是可以在高维空间中多分类出来的
* 代码模式的识别和模式归纳,用不可变的代码部分或者用的次数最多的部分作为代码生成器核心部分
