package main

import (
	"bytes"
	"encoding/json"
	"os"

	"text/template"

	"github.com/bitfield/script"
)

// Load inFile as a template, apply data to it, and write it out to outFile
func replaceTokens(inFile string, outFile string, data map[string]interface{}) {
	// load config file
	configFile, err := script.File(inFile).String()
	if err != nil {
		panic(err)
	}

	// validate template
	ty := template.Must(template.New("token-file").Parse(configFile))

	// parse the template
	var loadTheBytesHere bytes.Buffer
	err = ty.Option("missingkey=error").Execute(&loadTheBytesHere, data)
	if err != nil {
		panic(err)
	}
	script.NewPipe().WithReader(&loadTheBytesHere).WriteFile(outFile)
}

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

	replaceTokens("app/config/teleport.yaml", "app/config/teleport.yaml", varData)

	replaceTokens("terraform/00-providers.tf", "terraform/00-providers.tf", varData)

	replaceTokens(".ci/docker.sh", ".ci/docker.sh", varData)

	script.Exec(".ci/docker.sh").Stdout()

	os.Chdir("terraform")

	script.Args().Exec("../.ci/terraform.sh").Stdout()

}
