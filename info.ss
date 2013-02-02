#lang setup/infotab

(define name "MrEd Designer")
(define blurb
  `((p
     "Create Racket GUIs, WYSIWYG."
     (ul
     ; nope, now it's on github...
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
     (li "editor-canvas widget (Kieron Hardy)")
     (li "Racketify generated code")
     (li "Output to frame instead of to console")
     (li "Fixed tab-panel crash and remove need for single-panel")
     (li "MED Project version checking: displays a warning when a recent project file is read by an older version (though it should currently not be problematic)")
     (li "Added several false-or-text/number/etc. fields (Kieron Hardy)")
     )))
