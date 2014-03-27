
Defaults = {
  "attributes" => [
    "prefix" => "triki-dev",
    "username" => "innotechdev",
    "private_key_path" => "~/pems/innotechdev.pem"
  ],
  "scripts" => [
    { "path" => "./vagrant-deploy-common/scripts/routes_allregions.sh" },
    { "path" => "./vagrant-deploy-common/scripts/updatedns.sh", "args" => "%{name}" },
  ],
  "providers" => [
    "aws" => {
      "attributes" => [
        "instance_type" => "m1.small"
      ],
      "scripts" => [],
      "regions" => [
        # AWS Ireland a
        "eu-west-1a" => {
          "attributes" => [
            "keypair" => "vagrant-aws-ireland",
            "subnet_id" => "subnet-be457fca",
            "security_groups" => ["sg-576c7635","sg-1e648a7b"], # awsireland, triki
            "ami" => "ami-f5ca3682" # centos_base_v5
          ]
        },
        # AWS Oregon b
        "us-west-2b" => {
          "attributes" => [
            "keypair" => "vagrant-aws-oregon",
            "subnet_id" => "subnet-ef757e8d",
            "security_groups" => ["sg-88283cea","sg-f233ca97"], # awsoregon, triki
            "ami" => "ami-c66608f6" # centos_base_v5
          ]
        }
      ]
    },
    "gce" => {
      "attributes" => [
        "project_id" => "innotechapp",
        "client_email" => "388158271394-hiqo47ehuagjshtrtsgicsnn0uvmdk06@developer.gserviceaccount.com",
        "key_location" => "~/pems/70ddae97bf1c09d2d799b2acde33a03ebd52d774-privatekey.p12",
        "instance_type" => "m1.small"
      ],
      "scripts" => [],
      "regions" => [
        # GCE Ireland a
        "europe-west1-a" => {
          "attributes" => [
            "network" => "liberty-gce",
            "instance_type" => "n1-standard-1",
            "ami" => "centos-base-v5"
          ]
        }
      ]
    }
  ]
}

MachineTypes = {

}
