
Defaults = {
  "attributes" => {
    "prefix" => "triki-dev",
    "username" => "innotechdev",
    "private_key_path" => "~/pems/innotechdev.pem"
  },
  "authentication" => {
    :private_key_path => "~/.ssh/id_rsa",
    :public_key_path => "~/.ssh/id_rsa.pub",
    :username => "ubuntu"
  },
  "scripts" => [
    { "path" => "./vagrant-deploy-common/scripts/routes_allregions.sh" },
    { "path" => "./vagrant-deploy-common/scripts/updatedns.sh", "args" => "%{name}" },
  ],
  "providers" => [
    "aws" => {
      "attributes" => {
        "instance_type" => "m1.small"
      },
      "scripts" => [],
      "regions" => {
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
  }
}

MachineTypes = {
  "listener" => {
    "attributes" => [
      "index" => ["0","1","2","3","4","5","6","7","8"],
      "name" => "%{prefix}%{type}%{index}",
      "domain" => "topicthunder.io",
      "public_ip" => {
        "%{prefix}%{type}1" => "54.72.104.81",
        "%{prefix}%{type}4" => "54.72.61.208",
        "%{prefix}%{type}5" => "54.186.102.2",
        "%{prefix}%{type}6" => "54.186.114.247",
        "%{prefix}%{type}7" => "192.158.30.154",
        "%{prefix}%{type}8" => "23.251.134.155"
      }
    ],
    "scripts" => [
      #type = "listener"
      { "path" => "./scripts/configureNginx.sh", "args" => ["%{name}","%{type}%{index}","%{domain}"] },
      { "path" => "./scripts/configureListener.sh", "args" => ["%{hydra}"] },
      { "path" => "./vagrant-deploy-common/scripts/hydraProbe.sh", "args" => [
          "%{provider}-%{region}", # cloud
          "2", # local strategy
          "2", # cloud strategy
          "%{prize}", # prize
          "%{type}%{index}", # server name (without domain)
          "%type", # app_id
          "443", # app_port
          "%{hydra}", # hydra_host
          "/var/run/listener.pid", # pid file
          "%{domain}", # public domain
          "https" # protocol
      ]}
    ],
    "providers" => [
      "aws" => {
        "regions" => [
          "eu-west-1a" => {
            "attributes" => [
                "hydra" => "%{prefix}hydra4",
                "prize" => 5
            ]
          },
          "us-west-2b" => {
            "attributes" => [
                "hydra" => "%{prefix}hydra5",
                "prize" => 7
            ]
          }
        ]
      },
      "gce" => {
        "regions" => [
          "europe-west1-a" => {
            "attributes" => [
              "hydra" => "%{prefix}hydra6",
              "prize" => 4,
              "tags" => ["https"],
            ],
          }
        ]
      }
    ]
  }
}
