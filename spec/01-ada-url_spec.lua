local ada = require("resty.ada")


local assert = assert
local describe = describe
local it = it
local tostring = tostring


local same = assert.same
local equal = assert.equal
local is_nil = assert.is_nil
local is_true = assert.is_true
local is_false = assert.is_false
local is_table = assert.is_table
local errors = assert.errors


local function is_err(msg, ok, err)
  is_nil(ok)
  equal(msg, err)
  return ok, err
end


describe("Ada", function()
  describe("URL", function()
    describe(".parse", function()
      it("rejects invalid url", function()
        is_err("invalid url", ada.parse("<invalid>"))
      end)
      it("accepts valid url", function()
        is_table(ada.parse("http://www.google.com/"))
      end)
    end)
    describe(".parse_with_base", function()
      it("rejects invalid url", function()
        is_err("invalid url or base", ada.parse_with_base("<invalid>", "<invalid>"))
      end)
      it("accepts valid url", function()
        is_table(ada.parse_with_base("/path?search#hash", "http://www.google.com"))
      end)
    end)
    describe(".idna_to_ascii", function()
      it("translates unicode domain to ascii", function()
        equal("www.xn--7eleven-506c.com", ada.idna_to_ascii("www.7‑Eleven.com"))
      end)
    end)
    describe(".idna_to_unicode", function()
      it("translates ascii encoded domain to unicode", function()
        equal("www.7‐eleven.com", ada.idna_to_unicode("www.xn--7eleven-506c.com"))
      end)
    end)
    describe(".can_parse", function()
      it("rejects invalid url", function()
        is_false(ada.can_parse(".com:443/Home/Privacy/Montréal"))
        is_false(ada.can_parse("<invalid>"))
      end)
      it("accepts valid url", function()
        is_true(ada.can_parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
      end)
    end)
    describe(".can_parse_with_base", function()
      it("rejects invalid url", function()
        is_false(ada.can_parse_with_base("/path?search#hash", ".com:443/Home/Privacy/Montréal"))
        is_false(ada.can_parse_with_base("/path?search#hash", "<invalid>"))
        is_false(ada.can_parse_with_base("<invalid>", "http://"))
      end)
      it("accepts valid url", function()
        is_true(ada.can_parse_with_base("/path?search#hash", "http://www.google.com"))
      end)
    end)
    describe(".has_credentials", function()
      it("works", function()
        is_false(ada.has_credentials("https://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_true(ada.has_credentials("https://foo:bar@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_err("invalid url", ada.has_credentials("<invalid>"))
      end)
    end)
    describe(".has_non_empty_username", function()
      it("works", function()
        is_false(ada.has_non_empty_username("https://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_true(ada.has_non_empty_username("https://foo@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_err("invalid url", ada.has_non_empty_username("<invalid>"))
      end)
    end)
    describe(".has_password", function()
      it("works", function()
        is_false(ada.has_password("https://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_false(ada.has_password("https://foo@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_false(ada.has_password("https://foo:@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_true(ada.has_password("https://foo:bar@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_err("invalid url", ada.has_password("<invalid>"))
      end)
    end)
    describe(".has_non_empty_password", function()
      it("works", function()
        is_false(ada.has_non_empty_password("https://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_false(ada.has_non_empty_password("https://foo@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_false(ada.has_non_empty_password("https://foo:@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_true(ada.has_non_empty_password("https://foo:bar@www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        is_err("invalid url", ada.has_non_empty_password("<invalid>"))
      end)
    end)
    describe(".has_hostname", function()
      it("works", function()
        is_true(ada.has_hostname("https://www.7‑Eleven.com"))
        is_true(ada.has_hostname("file:///tmp/mock/path"))
        is_false(ada.has_hostname("non-spec:/.//p"))
        is_err("invalid url", ada.has_hostname("<invalid>"))
      end)
    end)
    describe(".has_empty_hostname", function()
      it("works", function()
        is_false(ada.has_empty_hostname("https://www.7‑Eleven.com"))
        is_true(ada.has_empty_hostname("file:///tmp/mock/path"))
        is_false(ada.has_empty_hostname("non-spec:/.//p"))
        is_err("invalid url", ada.has_empty_hostname("<invalid>"))
      end)
    end)
    describe(".has_port", function()
      it("works", function()
        is_false(ada.has_port("https://www.foo.com:443")) -- this is expected to return false on standard port
        is_false(ada.has_port("https://www.foo.com"))
        is_true(ada.has_port("https://www.foo.com:8888"))
        is_err("invalid url", ada.has_port("<invalid>"))
      end)
    end)
    describe(".has_search", function()
      it("works", function()
        is_true(ada.has_search("https://www.foo.com?foo=bar"))
        is_false(ada.has_search("https://www.foo.com"))
        is_err("invalid url", ada.has_search("<invalid>"))
      end)
    end)
    describe(".has_hash", function()
      it("works", function()
        is_true(ada.has_hash("https://www.foo.com?foo=bar#abc"))
        is_true(ada.has_hash("https://www.foo.com#abc"))
        is_false(ada.has_hash("https://www.foo.com"))
        is_err("invalid url", ada.has_hash("<invalid>"))
      end)
    end)
    describe(".get_components", function()
      it("works", function()
        local c = ada.get_components("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        equal(32, c.host_end)
        equal(9, c.host_start)
        equal(33, c.pathname_start)
        equal(7, c.protocol_end)
        equal(9, c.username_end)
        is_err("invalid url", ada.get_components("<invalid>"))
      end)
    end)
    describe(".get_href", function()
      it("works", function()
        local u, err = ada.get_href("https://user:pass@host:1234/path?search#hash")
        equal("https://user:pass@host:1234/path?search#hash", u)
        is_nil(err)
        is_err("invalid url", ada.get_href("<invalid>"))
      end)
    end)
    describe(".get_protocol", function()
      it("works", function()
        equal("https:", ada.get_protocol("https://www.foo.com"))
        is_nil(ada.get_protocol("www.foo.com?foo=bar"))
        is_err("invalid url", ada.get_protocol("<invalid>"))
      end)
    end)
    describe(".get_scheme_type", function()
      it("works", function()
        equal(2, ada.get_scheme_type("https://www.foo.com"))
        equal(1, ada.get_scheme_type("grpc://www.foo.com"))
        equal(0, ada.get_scheme_type("http://www.foo.com"))
        is_nil(ada.get_scheme_type("www.foo.com"))
        is_err("invalid url", ada.get_scheme_type("<invalid>"))
      end)
    end)
    describe(".get_origin", function()
      it("works", function()
        equal("https://www.foo.com", ada.get_origin("https://www.foo.com/foo/bar"))
        is_nil(ada.get_origin("www.foo.com/foo/bar"))
        is_err("invalid url", ada.get_origin("<invalid>"))
      end)
    end)
    describe(".get_username", function()
      it("works", function()
        equal("foo", ada.get_username("https://foo:bar@www.foo.com?foo=bar"))
        equal("", ada.get_username("https://:bar@www.foo.com?foo=bar"))
        equal("", ada.get_username("https://:@www.foo.com?foo=bar"))
        equal("", ada.get_username("https://www.foo.com?foo=bar"))
        is_err("invalid url", ada.get_username("<invalid>"))
      end)
    end)
    describe(".get_password", function()
      it("works", function()
        equal("bar", ada.get_password("https://foo:bar@www.foo.com?foo=bar"))
        equal("bar", ada.get_password("https://:bar@www.foo.com?foo=bar"))
        equal("", ada.get_password("https://:@www.foo.com?foo=bar"))
        equal("", ada.get_password("https://www.foo.com?foo=bar"))
        is_err("invalid url", ada.get_password("<invalid>"))
      end)
    end)
    describe(".get_host", function()
      it("works", function()
        equal("www.foo.com", ada.get_host("https://foo:bar@www.foo.com?foo=bar"))
        equal("127.0.0.1", ada.get_host("https://127.0.0.1/foo/bar"))
        is_err("invalid url", ada.get_host("<invalid>"))
      end)
    end)
    describe(".get_hostname", function()
      it("works", function()
        equal("www.foo.com", ada.get_hostname("https://foo:bar@www.foo.com?foo=bar"))
        equal("127.0.0.1", ada.get_hostname("https://127.0.0.1/foo/bar"))
        is_err("invalid url", ada.get_hostname("<invalid>"))
      end)
    end)
    describe(".get_host_type", function()
      it("works", function()
        equal(0, ada.get_host_type("https://foo:bar@www.foo.com?foo=bar"))
        equal(1, ada.get_host_type("https://127.0.0.1/foo/bar"))
        is_err("invalid url", ada.get_host_type("<invalid>"))
      end)
    end)
    describe(".get_port", function()
      it("works", function()
        equal("", ada.get_port("https://www.foo.com:443"))
        equal("", ada.get_port("https://www.foo.com"))
        equal(8888, ada.get_port("https://www.foo.com:8888"))
        is_err("invalid url", ada.get_port("<invalid>"))
      end)
    end)
    describe(".get_pathname", function()
      it("works", function()
        equal("/", ada.get_pathname("https://foo:bar@www.foo.com?foo=bar"))
        equal("/foo/bar", ada.get_pathname("https://127.0.0.1/foo/bar"))
        is_err("invalid url", ada.get_pathname("<invalid>"))
      end)
    end)
    describe(".get_search", function()
      it("works", function()
        equal("?foo=bar", ada.get_search("https://www.foo.com?foo=bar"))
        equal("?foo=bar&a=b&b=c", ada.get_search("https://www.foo.com?foo=bar&a=b&b=c"))
        equal("", ada.get_search("https://www.foo.com/"))
        equal("", ada.get_search("https://www.foo.com?"))
        is_err("invalid url", ada.get_search("<invalid>"))
      end)
    end)
    describe(".get_hash", function()
      it("works", function()
        equal("#foo-bar", ada.get_hash("https://www.foo.com?foo=bar#foo-bar"))
        equal("", ada.get_hash("https://www.foo.com#"))
        equal("", ada.get_hash("https://www.foo.com"))
        is_err("invalid url", ada.get_hash("<invalid>"))
      end)
    end)
    describe(".set_protocol", function()
      it("works", function()
        equal("http://www.xn--7eleven-506c.com/Home/Privacy/Montr%C3%A9al", ada.set_protocol("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "http"))
        equal("https:", ada.get_protocol("https://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        equal("http:", ada.get_protocol("http://www.7‑Eleven.com:443/Home/Privacy/Montréal"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        is_table(u:set_protocol("http"))
        equal("http:", u:get_protocol())
        is_table(u:set_protocol("https"))
        equal("https:", u:get_protocol())
        is_err("invalid url", ada.set_protocol("<invalid>", "http"))
        is_err("unable to set protocol", ada.set_protocol("http://www.7‑Eleven.com:443/Home/Privacy/Montréal", "1234"))
      end)
    end)
    describe(".set_username", function()
      it("works", function()
        equal("https://user@www.xn--7eleven-506c.com/Home/Privacy/Montr%C3%A9al", ada.set_username("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "user"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        is_table(u:set_username("user"))
        equal("user", u:get_username())
        is_err("invalid url", ada.set_username("<invalid>", "user"))
        is_err("unable to set username", ada.set_username("file:///doge", "pass"))
      end)
    end)
    describe(".set_password", function()
      it("works", function()
        equal("https://:pass@www.xn--7eleven-506c.com/Home/Privacy/Montr%C3%A9al", ada.set_password("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "pass"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        is_table(u:set_password("pass"))
        equal("pass", u:get_password())
        is_err("invalid url", ada.set_password("<invalid>", "pass"))
        is_err("unable to set password", ada.set_password("file:///doge", "pass"))
      end)
    end)
    describe(".set_host", function()
      it("works", function()
        equal("https://example.com/Home/Privacy/Montr%C3%A9al", ada.set_host("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "example.com"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        is_table(u:set_host("example.com"))
        equal("example.com", u:get_host())
        is_err("invalid url", ada.set_host("<invalid>", "example.com"))
        is_err("unable to set host", ada.set_host("foo://example.com", "exa[mple.org"))
      end)
    end)
    describe(".set_hostname", function()
      it("works", function()
        equal("https://example.com/Home/Privacy/Montr%C3%A9al", ada.set_hostname("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "example.com"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        is_table(u:set_hostname("example.com"))
        equal("example.com", u:get_host())
        is_err("invalid url", ada.set_hostname("<invalid>", "example.com"))
        is_err("unable to set hostname", ada.set_hostname("foo://example.com", "exa[mple.org"))
      end)
    end)
    describe(".set_port", function()
      it("works", function()
        equal("https://www.xn--7eleven-506c.com:1234/Home/Privacy/Montr%C3%A9al", ada.set_port("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", 1234))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy/Montréal")
        is_table(u:set_port(1234))
        equal(1234, u:get_port())
        is_err("invalid url", ada.set_port("<invalid>", 1234))
        is_err("unable to set port", ada.set_port("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "<invalid>"))
      end)
    end)
    describe(".set_pathname", function()
      it("works", function()
        equal("https://www.xn--7eleven-506c.com/Doge", ada.set_pathname("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "/Doge"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy")
        equal("/Home/Privacy", u:get_pathname())
        is_table(u:set_pathname("/foo/bar"))
        equal("/foo/bar", u:get_pathname())
        is_err("invalid url", ada.set_pathname("<invalid>", "/Doge"))
        is_err("unable to set pathname", ada.set_pathname("mailto:user@example.org", "/doge"))

      end)
    end)
    describe(".set_search", function()
      it("works", function()
        equal("https://www.xn--7eleven-506c.com/Home/Privacy/Montr%C3%A9al?foo=bar", ada.set_search("https://www.7‑Eleven.com:443/Home/Privacy/Montréal", "foo=bar"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy?foo=bar")
        equal("?foo=bar", u:get_search())
        is_table(u:set_search("bar=baz"))
        equal("?bar=baz", u:get_search())
        is_err("invalid url", ada.set_search("<invalid>", "foo"))
      end)
    end)
    describe(".set_hash", function()
      it("works", function()
        equal("https://www.xn--7eleven-506c.com/Home/Privacy?foo=bar#bar", ada.set_hash("https://www.7‑Eleven.com:443/Home/Privacy?foo=bar#foo", "#bar"))
        local u = ada.parse("https://www.7‑Eleven.com:443/Home/Privacy?foo=bar#foo")
        equal("#foo", u:get_hash())
        is_table(u:set_hash("#bar"))
        equal("#bar", u:get_hash())
        is_err("invalid url", ada.set_hash("<invalid>", "foo"))
      end)
    end)
    describe(".clear_port", function()
      it("works", function()
        equal("https://www.google.com/", ada.clear_port("https://www.google.com:8888/"))
        local u = ada.parse("https://www.google.com:8888/")
        equal("https://www.google.com/", tostring(u:clear_port()))
        is_err("invalid url", ada.clear_port("<invalid>"))
      end)
    end)
    describe(".clear_search", function()
      it("works", function()
        equal("https://www.google.com:8888/", ada.clear_search("https://www.google.com:8888?foo=bar"))
        local u = ada.parse("https://www.google.com:8888?foo=bar")
        equal("https://www.google.com:8888/", tostring(u:clear_search()))
        is_err("invalid url", ada.clear_search("<invalid>"))
      end)
    end)
    describe(".clear_hash", function()
      it("works", function()
        equal("https://www.google.com:8888/?foo=bar", ada.clear_hash("https://www.google.com:8888?foo=bar#bar"))
        local u = ada.parse("https://www.google.com:8888?foo=bar#bar")
        equal("https://www.google.com:8888/?foo=bar", tostring(u:clear_hash()))
        is_err("invalid url", ada.clear_hash("<invalid>"))
      end)
    end)
    describe(".search_parse", function()
      it("works", function()
        local s = ada.search_parse("https://www.google.com?doge=z&jack=2")
        is_table(s)
        equal("doge=z&jack=2", s:tostring())

        local url = ada.parse("https://www.google.com?doge=z&jack=2")
        s = url:search_parse()
        is_table(s)
        equal("doge=z&jack=2", s:tostring())

        is_err("invalid url", ada.search_parse("<invalid>"))
      end)
    end)
    describe(".search_has", function()
      it("works", function()
        is_true(ada.search_has("https://www.google.com?doge=z&jack=2", "jack"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2")
        is_true(u:search_has("jack"))
        is_err("invalid url", ada.search_has("<invalid>", "jack"))
      end)
    end)
    describe(".search_has_value", function()
      it("works", function()
        is_false(ada.search_has_value("https://www.google.com?doge=z&jack=2", "jack", "4"))
        is_true(ada.search_has_value("https://www.google.com?doge=z&jack=2", "jack", "2"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2")
        is_false(u:search_has_value("jack", "4"))
        is_true(u:search_has_value("jack", "2"))
        is_err("invalid url", ada.search_has_value("<invalid>", "jack", "2"))
      end)
    end)
    describe(".search_get", function()
      it("works", function()
        equal("2", ada.search_get("https://www.google.com?doge=z&jack=2", "jack"))
        is_nil(ada.search_get("https://www.google.com?doge=z&jack=2", "foo"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2")
        equal("2", u:search_get("jack"))
        is_nil(u:search_get("foo"))
        is_err("invalid url", ada.search_get("<invalid>", "jack"))
      end)
    end)
    describe(".search_get_all", function()
      it("works", function()
        same({}, ada.search_get_all("https://www.google.com?doge=z&jack=2&doge=s", "missing"))
        same({"z", "s"}, ada.search_get_all("https://www.google.com?doge=z&jack=2&doge=s", "doge"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s")
        same({"z", "s"}, u:search_get_all("doge"))
        is_err("invalid url", ada.search_get_all("<invalid>", "doge"))
      end)
    end)
    describe(".search_set", function()
      it("works", function()
        equal("https://www.google.com/?doge=z&jack=4", ada.search_set("https://www.google.com?doge=z&jack=2", "jack", "4"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2")
        equal("https://www.google.com/?doge=z&jack=4", tostring(u:search_set("jack", "4")))
        is_err("invalid url", ada.search_set("<invalid>", "jack", "4"))
      end)
    end)
    describe(".search_append", function()
      it("works", function()
        equal("https://www.google.com/?doge=z&jack=2&doge=z", ada.search_append("https://www.google.com?doge=z&jack=2", "doge", "z"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2")
        equal("https://www.google.com/?doge=z&jack=2&doge=z", tostring(u:search_append("doge", "z")))
        is_err("invalid url", ada.search_append("<invalid>", "jack", "4"))
      end)
    end)
    describe(".search_remove", function()
      it("works", function()
        equal("https://www.google.com/?jack=2&bug=&aa=3", ada.search_remove("https://www.google.com?doge=z&jack=2&doge=s&bug&aa=3", "doge"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug&aa=3")
        equal("https://www.google.com/?jack=2&bug=&aa=3", tostring(u:search_remove("doge")))
        is_err("invalid url", ada.search_remove("<invalid>", "doge"))
      end)
    end)
    describe(".search_remove_value", function()
      it("works", function()
        equal("https://www.google.com/?doge=z&jack=2&doge=s&bug=&aa=3", ada.search_remove_value("https://www.google.com?doge=z&jack=2&doge=s&bug&aa=3", "doge", "t"))
        equal("https://www.google.com/?jack=2&doge=s&bug=&aa=3", ada.search_remove_value("https://www.google.com?doge=z&jack=2&doge=s&bug&aa=3", "doge", "z"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug&aa=3")
        equal("https://www.google.com/?doge=z&jack=2&doge=s&bug=&aa=3", tostring(u:search_remove_value("doge", "t")))
        u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug&aa=3")
        equal("https://www.google.com/?jack=2&doge=s&bug=&aa=3", tostring(u:search_remove_value("doge", "z")))
        is_err("invalid url", ada.search_remove_value("<invalid>", "doge", "z"))
      end)
    end)
    describe(".search_each", function()
      it("works", function()
        local args = {
          doge = true,
          jack = true,
          bug = true,
          aa = true,
          bb = true,
        }

        for t in ada.search_each("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[t.key])
        end

        for t in ada.search.each("?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[t.key])
        end

        local url = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10")
        for t in url:search_each() do
          is_true(args[t.key])
        end

        is_err("invalid url", ada.search_each("<invalid>"))
      end)
    end)
    describe(".search_each_key", function()
      it("works", function()
        local args = {
          doge = true,
          jack = true,
          bug = true,
          aa = true,
          bb = true,
        }

        for k in ada.search_each_key("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[k])
        end

        for k in ada.search.each_key("?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[k])
        end

        local url = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10")
        for k in url:search_each_key() do
          is_true(args[k])
        end

        is_err("invalid url", ada.search_each_key("<invalid>"))
      end)
    end)
    describe(".search_each_value", function()
      it("works", function()
        local args = {
          z = true,
          ["2"] = true,
          s = true,
          [""] = true,
          ["3"] = true,
          ["4"] = true,
          ["10"] = true,
        }

        for v in ada.search_each_value("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[v])
        end

        for v in ada.search.each_value("?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[v])
        end

        local url = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10")
        for v in url:search_each_value() do
          is_true(args[v])
        end

        is_err("invalid url", ada.search_each_value("<invalid>"))
      end)
    end)
    describe(".search_pairs", function()
      it("works", function()
        local args = {
          doge = true,
          jack = true,
          bug = true,
          aa = true,
          bb = true,
        }

        for k in ada.search_pairs("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[k])
        end

        for k in ada.search.pairs("?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[k])
        end

        local url = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10")
        for k in url:search_pairs() do
          is_true(args[k])
        end

        is_err("invalid url", ada.search_pairs("<invalid>"))
      end)
    end)
    describe(".search_ipairs", function()
      it("works", function()
        local args = {
          doge = true,
          jack = true,
          bug = true,
          aa = true,
          bb = true,
        }

        for _, v in ada.search_ipairs("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[v.key])
        end

        for _, v in ada.search.ipairs("?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10") do
          is_true(args[v.key])
        end

        local url = ada.parse("https://www.google.com?doge=z&jack=2&doge=s&bug=&aa=3&bb=4&bb=10")
        for _, v in url:search_ipairs() do
          is_true(args[v.key])
        end

        is_err("invalid url", ada.search_ipairs("<invalid>"))
      end)
    end)
    describe(".search_sort", function()
      it("works", function()
        equal("https://www.google.com/?doge=z&doge=s&jack=2", ada.search_sort("https://www.google.com?doge=z&jack=2&doge=s"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s")
        equal("https://www.google.com/?doge=z&doge=s&jack=2", tostring(u:search_sort()))
        is_err("invalid url", ada.search_sort("<invalid>"))
      end)
    end)
    describe(".search_size", function()
      it("works", function()
        equal(3, ada.search_size("https://www.google.com?doge=z&jack=2&doge=s"))
        local u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s")
        equal(3, u:search_size())
        is_err("invalid url", ada.search_size("<invalid>"))
      end)
    end)
    describe(":set_href", function()
      it("works", function()
        local u = ada.parse("https://localhost")
        is_table(u:set_href("https://www.google.com?doge=z&jack=2&doge=s"))
        equal("www.google.com", u:get_hostname())
        is_err("unable to set href", u:set_href("<invalid>"))
        equal("www.google.com", u:get_hostname())
      end)
    end)
    describe(":free", function()
      it("works", function()
        local u = ada.parse("https://www.google.com?doge=z&jack=2&doge=s")
        equal("www.google.com", u:get_hostname())
        u:free()
        errors(function() u:get_hostname() end, "attempt to call method 'get_hostname' (a nil value)")
      end)
    end)
    describe("__len metamethod", function()
      it("works", function()
        local u = ada.parse("https://www.google.com/?doge=z&jack=2&doge=s")
        equal(44, #u)
      end)
    end)
  end)
  describe("Search", function()
    describe(":free", function()
      it("works", function()
        local s = ada.search.parse("doge=z&jack=2&doge=s")
        equal("2", s:get("jack"))
        s:free()
        errors(function() s:get("jack") end, "attempt to call method 'get' (a nil value)")
      end)
    end)
  end)
end)
