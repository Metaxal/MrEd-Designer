#lang scheme

(require "../../mred-plugin.ss"
         "../../default-values.ss"
         "preview.ss"
         scheme/gui/base)

(make-plugin
 [type 'project]
 [tooltip "Project"]
 [button-group #f] ; no button
 [widget-class project%]
; [code-gen-class frame%] ; the class used in the generated code for the widgets of this plugin
 [parent-class #f]
 [pre-code (λ(mid)(if (send mid get-property-value 'runtime-paths?)
                      '((require scheme/runtime-path))
                      '()))]
 [necessary '(parent)] ; necessary properties (not used yet)
 ;[options '(id)] ; options of the init-function in the generated code
 [no-code '(file code-file code-requires changed runtime-paths?)] ; don't generate this field in the generated file
 [hidden '(file label style code-file changed)] ; don't show this in the property frame
 ( ; widget properties
  [file #f] ; file to save the project to
  [code-file #f] ; file to generate the code to. Should be relative to file ?
  [changed #f] ; has the project changed since last save?
  [code-requires '("framework")] ; list of modules that the generated code needs
  [runtime-paths? #f] ; do we use runtime-paths in the generated code?
  ))
