# MrEd Designer 3.x

MrEd Designer is WYSIWYG program to create GUI applications for [Racket](http://www.racket-lang.org/) (ex PLT Scheme).


Complete documentation and screenshots: https://github.com/Metaxal/MrEd-Designer/wiki

## Installation

In DrRacket: Select `File > Install a package...` and choose `mred-designer`.

Or from the command line, type:
```shell
raco pkg install mred-designer
```

## Quick Start

To start MrEd Designer, either type in the interactions window in DrRacket:
```racket
(require mred-designer)
```
or from the command line (recommended):
```shell
racket -l mred-designer
```

MrEd Designer starts with an empty project.

1. Click on the "frame" button ![Frame](https://raw.githubusercontent.com/Metaxal/MrEd-Designer/master/mred-designer/widgets/frame/icons/24x24.png) in the Main Panel; this adds a frame to the project. The (small) frame appears on the screen and a new entry appears below the project name in the Hierarchy Panel.
2. Select the frame, either by clicking inside it, or by clicking on its name in the Hierarchy Panel.
Then add some widgets from the Main Panel.
3. Click on `File > Generate Racket file...` and save the code to some place. (Note that this only generates a Racket file but does not save your MrEd Designer project for further editing.) 
4. Finally, either open the saved file in DrRacket and execute it, or call with from the command line as you would do for any racket file.
You should now see the frame that you have created.

If you have difficulties using MrEd Designer, or for any other comment, you can contact me (laurent orseau gmail com) or file an [issue](https://github.com/Metaxal/MrEd-Designer/issues).
