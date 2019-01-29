{:1.6 {:plugins ^:replace [[cider/cider-nrepl "0.10.2"]
                           [refactor-nrepl "2.0.0"]]}
 :user
 {:repl-options {:timeout 12000000}
  :jvm-opts ["-XX:-OmitStackTraceInFastThrow"]
  :plugins [;; REPL
            [lein-try "0.4.3"]

            ;; Application server
            [lein-immutant "2.1.0"]

            ;; Automated testing
            [lein-cloverage "1.0.10"]
            [lein-test-out "0.3.1" :exclusions [org.clojure/tools.namespace]]

            ;; Package management
            [lein-ancient "0.6.14" :exclusions [org.clojure/clojure]]
            [lein-licenses "0.2.0"]

            ;; Documentation
            [codox "0.10.1"]
            [lein-clojuredocs "1.0.2"]

            ;; Static analysis
            [lein-typed "0.3.5"]
            [jonase/eastwood "0.3.4"]
            [lein-bikeshed "0.4.0"  :exclusions [org.clojure/tools.namespace]]
            [lein-kibit "0.1.6" :exclusions [org.clojure/clojure]]]}
 :repl {:repl-options {:init (set! *print-length* 100)} ;;https://github.com/clojure-emacs/cider/commit/0e35ce1eb484b88d9314c09d47a9510ff08b219f
        :plugins [[cider/cider-nrepl "0.20.0"]
                  [refactor-nrepl "2.4.0"]]
        :dependencies [[org.clojars.gjahad/debug-repl "0.3.3"]
                       [difform "1.1.2"]

                       [spyscope "0.1.5"] ;;;use 0.1.6 for Clojure 1.7+
                       [org.clojure/tools.trace "0.7.8"]
                       [org.clojure/tools.namespace "0.2.11"]
                       [alembic "0.3.2"]
                       [im.chit/lucid.core.inject "1.2.0"]
                       [im.chit/lucid.mind "1.2.0"]
                       [io.aviso/pretty "0.1.31"]

                       [slamhound "1.5.5"]
                       [criterium "0.4.4"]]
        :injections [(require 'spyscope.core)
                     (require '[lucid.core.inject :as inject])
                     (inject/in [lucid.core.inject :refer [inject [in inject-in]]]
                                [clojure.pprint pprint]
                                [clojure.java.shell sh]
                                [alembic.still [distill pull] lein [load-project pull-project]]
                                [clojure.tools.namespace.repl refresh]
                                [clojure.repl doc source]

                                clojure.core
                                [lucid.mind .& .> .? .* .% .%> .>var .>ns])]}}
