#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)

(make-plugin
 [type 'menu]
 [tooltip "Menu"]
 [button-group "Menu"]
 [widget-class menu%]
 [parent-class (list menu% popup-menu% menu-bar%)]
 [necessary '(label parent)]
 [options '(demand-callback)]
 ( ; widget properties
  [label "&Menu"]
  [help-string "Menu"]
  [demand-callback (prop:code (lambda (m) (void)))]
  ))
