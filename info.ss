#lang setup/infotab

(define name "MrEd Designer")
(define blurb
  `((p
     "Create Racket GUIs, WYSIWYG."
     (ul
      (li (a ((href "http://mred-designer.origo.ethz.ch"))
             "Homepage"))
      (li (a ((href "http://mred-designer.origo.ethz.ch/wiki/doc"))
             "User's documentation"))
      (li (a ((href "http://mred-designer.origo.ethz.ch/wiki/developer_doc"))
             "Developer's documentation"))
      )
     )))
(define primary-file "main.ss")
(define categories '(devtools misc ui))
(define homepage "http://mred-designer.origo.ethz.ch")
(define required-core-version "4.2.4")
;(define version "3.3")
(define repositories '("4.x"))
(define release-notes 
  '((ul
     (li "added: can now take projects as command line arguments. Ex: gracket main.ss my-project.med")
     (li "fixed: tab-panel child selection bug when empty child list")
     (li "fixed (Kieron Hardy): tooltip.ss was not always removing tooltip on windows")
     (li "fixed (Kieron Hardy): mreddesigner.bat : small DOS issues")
     )))
