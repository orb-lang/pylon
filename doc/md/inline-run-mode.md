# Running Code Inline In Orb


As always, a balance between implicit and ease of reasoning must be struck\.

The default is to knit, unless the `#noKnit` tag is applied\.

We have a syntax for executing a block, which we aren't yet using, hence the
design doc, looks like this:

```lua
print "what does this do?"
```

I say that, by default, this isn't knitted, and would need a `#knit` tag to be
included in the source document\.

This default is important because code which is executed only overlaps
deliberately which code which should be compiled, and requiring a `#noKnit`,
in addition to being noisy, makes the wrong decision the default\.


### Configurability

  I intend basically any arbitrary decision to be configurable through the
Manifest\.  So I won't burn many cycles spelling out alternatives\.


### The Now Environment

We start with what we have: an executable dynamic runtime called bridge, with
Lua as the only imperative dialect fully supported \(enough C to get by\!\)\.

We load the return value as the leaf portion of the module name, capitalized\.


#### Codeblock Assumptions

We use an implicit return style\.

This involves small rewrites which let us execute the whole block in order,
where order is ultimately under our control, defaulting to the expected
downward flow\.

The basic rules are these, in this order:


-  If a block contains `print` calls, the output is of type `text` and
    consists of what's printed\.


-  If the block consists of a `do` statement, containing return values, the
    output is of type `$tbd` and is the return values of that do block


-  otherwise, the last line may take rvalue form, consisting of, for example,
    a single variable\.  As though `_ = final` were the form\.


-  If it instead consists of a statement, that statement is executed verbatim,
    there is no return value, and Orb will complain if an attempt is made to
    refer to one\.


-  If the final line contains a return statement, this is **illegal** and the
    script will refuse to execute\.  By default this will follow the error train
    and rollback any changes Orb/scry were in the process of making\.


If we want to return from a block, we wrap in a `do` block, like so

```lua
do
   if flip() then
      return "came up true"
   else
      return "came up false"
   end
end
```

Otherwise the inline runner will refuse to execute the script\.


### Returns

  One of the fancier and more wondrous things `org-babel` does, is transform
results into various common currencies\.

\#TODO

