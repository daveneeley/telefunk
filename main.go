package main

import (
	"encoding/json"
	"os"

	"text/template"

	"github.com/bitfield/script"
)

func main() {
	// load vars from json
	varBytes, err := script.File("terraform/local.auto.tfvars.json").Bytes()
	if err != nil {
		panic(err)
	}

	// convert json to map[string]
	var varData map[string]interface{}
	if err := json.Unmarshal(varBytes, &varData); err != nil {
		panic(err)
	}

	// load teleport config
	teleportConfig, err := script.File("app/config/teleport.yaml").String()
	if err != nil {
		panic(err)
	}

	// setup teleport template
	ty := template.Must(template.New("teleport-yaml").Parse(teleportConfig))

	// parse the teleport template
	err = ty.Option("missingkey=error").Execute(os.Stdout, varData)
	if err != nil {
		panic(err)
	}

	// load the main
	mainTf, err := script.File("terraform/00-providers.tf").String()
	if err != nil {
		panic(err)
	}

	mtf := template.Must(template.New("terraform-providers").Parse(mainTf))

	err = mtf.Option("missingkey=error").Execute(os.Stdout, varData)
	if err != nil {
		panic(err)
	}

}
