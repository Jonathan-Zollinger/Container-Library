[![Build](https://github.com/Jonathan-Zollinger/PeanutButter-Unicorn/actions/workflows/validate-build.yml/badge.svg)](https://github.com/Jonathan-Zollinger/PeanutButter-Unicorn/actions/workflows/validate-build.yml) &ensp; &ensp; [![Publish Docker Images](https://github.com/Jonathan-Zollinger/PeanutButter-Unicorn/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Jonathan-Zollinger/PeanutButter-Unicorn/actions/workflows/docker-image.yml)

## Contributing

### Style Guide
- <a id='filenames'>__Directories__ and __Files__ </a> are to be properly capitalized ASCII letters. Words should be separated by single underscores unless noted otherwise in this styleguide.
- <a id='line-endings'>__Line Endings__</a> are to be [`LF` style line endings](https://developer.mozilla.org/en-US/docs/Glossary/CRLF) (`\n`), no matter the operating system.  
- <a id='variables'>__Variables__</a> and methods are to be meaningful names relative to their role or value. Abbreviations and single letter names are not acceptable, no matter the language. 
<ul>

> :clipboard: Readable code is self documenting code. There is no shortage of space in which to write your code, thus there is no acceptable reason to forego quickly comprehendable coding practices. 
</ul>

- <a id='tests'>__Tests__</a> are to be included for all functions / methods. Tests are to be mainly comprised of Unit tests with end-to-end tests included when applicable. 

#### Powershell
- <a id='ps-variables'>__Classes__ and __Variables__ </a> should conform to [pascal case](https://techterms.com/definition/pascalcase).
- <a id='ps-line-length'>__line lengths__
- <a id='ps-functions'> __Functions__ </a>are to be written in pascal case within the `Verb-Noun` pattern, where verbs are to be limited to approved verbs. 
<ul>

> :bulb: call "[Get-Verb](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-verb?view=powershell-7.2)" from a Powershell session for a list of approved verbs
</ul>

#### Examples of invalid function names:
```powershell  
  # Verbs must be found in the list of approved verbs
  function PowerOn-Computer{...}

  # Functions are to have hyphens (-) between the verb and noun
  function GetSnapshot{...}
```
#### Examples of properly named functions:
```Powershell
# Properly named Functions

  function Start-MyComputer{...}

  function Get-Snapshot{...}
```

- <a id='ps-doc-comments'> __Doc Comments__ </a> or '[comment-based help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2)' are to be included in all powershell functions. These comments are to be included after the function declaration but before the parameter assignments. Required tags include: 
  - [Synopsis](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2#Synopsis) or [description](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2#declaration)
<br>&emsp;_A Synopsis is a brief summary. A description is a more detailed Synopsis._
  - _All_ [parameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2#parameter) and switches (Mandatory or otherwise)
  - [Inputs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2#inputs)
  - [Outputs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2#outputs)
  - Atleast one [example](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2#example)
- <a id='ps-tests'>__Tests__</a> are to be written using [pester](https://pester.dev/docs/quick-start#creating-a-pester-test).
