#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         scheme/gui/base)

(make-plugin
 [type 'menu-bar]
 [tooltip "Menu Bar"]
 [button-group "Menu"]
 [widget-class menu-bar%]
 [parent-class (λ(mid-parent)(and (is-a? mid-parent frame%)
                                  (not (send mid-parent get-menu-bar))))]
;  frame%]
 [necessary '(parent)]
 [options '(demand-callback)]
 ( ; widget properties
  [demand-callback (prop:code (lambda (m) (void)))]
  ))
