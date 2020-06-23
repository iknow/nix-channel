{
  deep_merge = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1q3picw7zx1xdkybmrnhmk2hycxzaa0jv4gqrby1s90dy5n7fmsb";
      type = "gem";
    };
    version = "1.2.1";
  };
  hashdiff = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ncwxv7jbm3jj9phv6dd514463bkjwggxk10n2z100wf4cjcicrk";
      type = "gem";
    };
    version = "0.4.0";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xy54mjf7xg41l8qrg1bqri75agdqmxap9z466fjismc1rn2jwfr";
      type = "gem";
    };
    version = "1.14.1";
  };
  oj = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jli4mi1xpmm8564pc09bfvv7znzqghidwa3zfw21r365ihmbv2p";
      type = "gem";
    };
    version = "2.18.5";
  };
  parallel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17b127xxmm2yqdz146qwbs57046kn0js1h8synv01dwqz2z1kp2l";
      type = "gem";
    };
    version = "1.19.2";
  };
  phraseapp-ruby = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14n2hhwjn32xk0qk6rprs3awnrddhnd4zckyd0a4j8lv8k648pnn";
      type = "gem";
    };
    version = "1.6.0";
  };
  phraseapp_updater = {
    dependencies = ["deep_merge" "hashdiff" "multi_json" "oj" "parallel" "phraseapp-ruby" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rz5m4jycqkh2s2ins53shc1k06xq8gj5d0vin9s8kdg82kan2d2";
      type = "gem";
    };
    version = "2.1.1";
  };
  thor = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
    version = "0.20.3";
  };
}