Used this command to create a managable sample to work with

```
find . -name '*.txt' -type f -exec sh -c 'head -n 500 <"$0" >"$0.sample"' {} \;
```

OK 
