#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'choice]
 [tooltip "Choice"]
 [button-group "Controls"]
 [widget-class choice%]
 [parent-class container-classes]
 [necessary '(label choices parent)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label (prop:false-or-string "Choice")]
  [choices '("First" "Second")]
  [callback (prop:code (lambda (choice control-event) (void)))]
  [style (prop:proc
          (prop:group (prop:one-of '(vertical-label horizontal-label)
                                   'horizontal-label)
                      (prop:some-of '(deleted) '()))
          (λ(l)(list* (first l) (second l))))]
  [font (font-values)]
  [selection 0]
  [enabled #t]
  [vert-margin 2]
  [horiz-margin 2]
  [min-width 0]
  [min-height 0]
  [stretchable-width #f]
  [stretchable-height #f]
  ))
