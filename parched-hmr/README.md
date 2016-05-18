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

### Install and configure needed dependencies

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

### Set up your app

This is a hypothetical `app/scripts/index.js`:

```javascript
// This needs to be first
import 'react-hot-loader/patch'

import { AppContainer } from 'react-hot-loader'
import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'

const rootEl = document.getElementById('cosmos')

ReactDOM.render(
  <AppContainer component={App} />,
  rootEl
)

if (module.hot) {
  module.hot.accept('./App', () => {
    // The `require()` here is needed. Using `App` imported above won't work.
    ReactDOM.render(
      <AppContainer component={require('./App').default} />,
      rootEl
    )
  })
}
```
