#lang racket

(require "../../mred-plugin.rkt"
         "../../default-values.rkt"
         racket/gui/base)

(define dft-prefix (get-default-shortcut-prefix))

(make-plugin
 [type 'menu-item]
 [tooltip "Menu Item"]
 [button-group "Menu"]
 [widget-class menu-item%]
 [parent-class (list menu% popup-menu%)]
 [necessary '(label parent)]
 [options '(demand-callback callback)]
 ( ; widget properties
  [label "&Item"]
  [callback (prop:code (lambda (item event) (void)))]
  [shortcut (shortcut-values)]
  [help-string (prop:false-or-string "Item")]
  [demand-callback (prop:code (lambda (item) (void)))]
  [shortcut-prefix (prop:some-of '(alt cmd meta ctl shift option) dft-prefix)]
  ))
