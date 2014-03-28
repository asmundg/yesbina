(import flask)
(import [flask.ext.jsonify [jsonify]])
(import yesbina.api)

(def app (flask.Flask "__main__"))

(with-decorator (app.route "/<stopid>/<line>") jsonify
  (defn departures [stopid line]
    (yesbina.api.get-departures stopid line)))

(with-decorator (app.route "/<line>/stops") jsonify
  (defn line-stops [line]
    (yesbina.api.line-stops line)))

(with-decorator (app.route "/<line>") jsonify
  (defn interesting-departures [line]
    (yesbina.api.interesting-departures line)))



