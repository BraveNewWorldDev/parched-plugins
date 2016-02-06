# parched-autoprefixer

You will want to have this plugin run last, so it will work on any
css/sass/less/etc files.

```javascript
Parched.setup({
  plugins: {
    order: {
      after: [
        'parched-autoprefixer'
      ]
    }
  }
})
```
