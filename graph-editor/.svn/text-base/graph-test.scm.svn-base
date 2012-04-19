; This is simple program to test the graph editor


(module graph-test mzscheme
  
(require (lib "class.ss")  
         (lib "mred.ss" "mred")
         (file "graph-editor.ss")
)


  
  (define w (new frame% (label "test")))
  (define c (new graph-editor% 
                 (parent w)
                 (min-width 600)
                 (min-height 300)
                 ))
  
  
  (define a1 (send c node-add "aa" 50 50 '()))
  (send c node-add "bb" 60 60 '())
  (send c node-add "cc" 61 40 '())
  (send c node-add "dd" 62 40 '())
  
  (define h1 (new horizontal-panel% (parent w) (alignment '(center center))))
  (define ba (new button%
                  (label "incr input tab")
                  (parent h1)
                  (callback (lambda (b e)
                              (let
                                ((selected (send c get-selected)))
                                (if selected
                                  (send selected tab-in-incr)))))))
  (define bd (new button%
                  (label "decr input tab")
                  (parent h1)
                  (callback (lambda (b e)
                              (let
                                ((selected (send c get-selected)))
                                (if selected
                                  (send selected tab-in-decr)))))))
  
  (define h2 (new horizontal-panel% (parent w)(alignment '(center center))))
  (define b3 (new button%
                  (label "incr output tab")
                  (parent h2)
                  (callback (lambda (b e)
                              (let
                                ((selected (send c get-selected)))
                                (if selected
                                  (send selected tab-out-incr)))))))
  (define b4 (new button%
                  (label "decr output tab")
                  (parent h2)
                  (callback (lambda (b e)
                              (let
                                ((selected (send c get-selected)))
                                (if selected
                                  (send selected tab-out-decr)))))))
   
  (send w show #t)
  
  
)