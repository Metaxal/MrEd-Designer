#lang racket

(require "../../mred-plugin.rkt"
         racket/gui/base)

(define dft-prefix (get-default-shortcut-prefix))

(make-plugin
 [type 'separator-menu-item]
 [tooltip "Separator Menu Item"]
 [button-group "Menu"]
 [widget-class separator-menu-item%]
 [parent-class (list menu% popup-menu%)]
 [necessary '(label parent)]
 [options '(demand-callback callback)]
 ( ; widget properties
  ))
