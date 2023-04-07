import React from "react";
import "./App.css";

const App = () => {
  return (
    <html>
      <head>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link href="/dist/output.css" rel="stylesheet" />
      </head>
      <body>
        <h1 className="text-3xl font-bold underline">Hello world!</h1>
      </body>
    </html>
  );
};

export default App;
