#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)


(make-plugin
 [type 'list-box]
 [tooltip "List Box"]
 [button-group "Controls"]
 [widget-class list-box%]
 [parent-class container-classes]
 [necessary '(label choices parent)] ; necessary properties
 [options '(callback)]
 ( ; widget properties
  [label "List Box"]
  [choices '("First" "Second")]
  [callback (prop:code (lambda (list-box control-event) (void)))]
  [style (prop:proc
          (prop:group (prop:one-of (list 'single 'multiple 'extended)
                                   'single)
                      (prop:one-of '(vertical-label horizontal-label)
                                   'horizontal-label)
                      (prop:some-of '(deleted) '()))
          (λ(l)(list* (first l) (second l) (third l))))]
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
