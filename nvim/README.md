# Neovim Readme

## External tools
Some of the plugins here require external tools to function

 - *Skim* - a pdf viewer

## LaTeX Notes
 - `:VimtexCompile` should compile the LaTeX and open *Skim* the pdf viewer. Every time you save `:w` the LaTeX file, the PDF viewer will update after a couple seconds.
 - [See Vimtex's docs for keyboard shortcuts](https://github.com/lervag/vimtex/blob/master/VISUALS.md)
 - `]]` and `[[` to jump between sections/subsections/paragraphs
 - Up/down arrows move by visual (wrapped) line. j/k move by actual line number.
 - `dsc` is "delete" "surrounding" "command" for simple commands `\emph{asdf}` -> `asdf`
 - `dse` is "delete" "surrounding" "environment" for multiline environments `\begin{itemize} asdf \end{itemize}` -> `asdf`
 - can swap first `d` ("delete") for `c` ("change") or `t` ("toggle")
 - can swap third letter for `d` to change delimiters (`[]`, `{}`, `()`, `\left`, `\big`, etc) or `$` to change math delimiters

## Markdown Notes
 - `<Ctrl> + <click>` to open links
 - `fe` in normal mode to open file tree
 - `ff` in normal mode to open file search

