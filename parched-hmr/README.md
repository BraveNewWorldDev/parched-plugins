# parched-hmr

## Getting Started

You will need to tell `parched-tasks-webapp` that your bundles have HMR
support:

```javascript
Parched.setup({
  gulp: gulp,

  webapp: {
    bundles: {
      app: {
        hasHMR: true,
      }
    }
  }
})
```

## Using with React

```bash
npm install --save parched-babel react-hot-loader@^3.0.0-alpha.13 babel-preset-react
mv .babelrc .babelrc~

cat <<-EOF > .babelrc
{
  "presets": [
    "react"
  ],
  "plugins": [
    "react-hot-loader/babel"
  ]
}
EOF
```
