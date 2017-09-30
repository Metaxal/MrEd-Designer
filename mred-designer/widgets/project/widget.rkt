#lang racket

(require "../../mred-plugin.rkt"
         "preview.rkt")

(make-plugin
 [type 'project]
 [tooltip "Project"]
 [button-group #f] ; no button
 [widget-class project%]
 [parent-class #f]
 [pre-code (λ(mid)(if (send mid get-property-value 'runtime-paths?)
                      '((require racket/runtime-path))
                      '()))]
 [necessary '(parent)] ; necessary properties (not used yet)
 ;[options '(id)] ; options of the init-function in the generated code
 ; don't generate this field in the generated file:
 [no-code '(file code-file code-requires changed runtime-paths?)]
 [hidden '(file label style code-file changed)] ; don't show this in the property frame
 ( ; widget properties
  [file #f] ; file to save the project to
  [code-file #f] ; file to generate the code to. Should be relative to file ?
  [changed #f] ; has the project changed since last save?
  ; list of modules that the generated code needs:
  [code-requires '(#;"framework" "racket/gui/base" "racket/class" "racket/list")] 
  [runtime-paths? #f] ; do we use runtime-paths in the generated code?
  ))
