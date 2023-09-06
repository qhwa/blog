-- title: Setting Proxy for Git
-- date: 2023-09-04
-- tags: git, proxy

![title-image](/post-images/proxied-git.png)

Git proxies can be a bit tricky to set up, as my recent experience helping a friend showed. But after some trial and error, we finally got it working. In this article, I'll share the insights and lessons learned from our journey.

### Some Basics

When it comes to proxies for Git, there are two main protocols to consider: SOCKS and HTTP. Both of these can be used seamlessly with Git. Nowadays, when we mention SOCKS, we almost always refer to SOCKS5. In this article, I'll use SOCKS5 as an example.

Git also supports two primary remote URL protocols: HTTP(s) and SSH. For instance, `https://github.com/user/repo.git` is an HTTP(s) remote URL, while `ssh://github.com/user/repo.git` is an SSH remote URL.

### Set it up

Let's dive into setting up Git proxies with different configurations:

| Git Protocol | Proxy Protocol | Configuration File | Config |
| ------------- | ------------- | ----------------- | ------- |
| HTTP(s) | HTTP | ~/.gitconfig | `git config --global http.proxy http://127.0.0.1:1080`|
| HTTP(s) | SOCKS | ~/.gitconfig | `git config --global http.proxy socks5h://127.0.0.1:1080` |
| SSH | HTTP | ~/.ssh/config | <code>Host github.com<br>&nbsp;&nbsp;ProxyCommand nc -v -X connect -x 127.0.0.1:1080 %h %p</code> |
| SSH | SOCKS | ~/.ssh/config | <code>Host github.com<br>&nbsp;&nbsp;ProxyCommand nc -v -X 5 -x 127.0.0.1:1080 %h %p</code>|

### Some Tips

Here are a few tips:

* The `git config http.proxy` setting also covers HTTPS URLs.
* You can use `http.proxy` for conditional proxying by domains. For example:

    ```
    [http "https://example.com/"]
      http.proxy = socks5h://127.0.0.1:1080
    ```

* The `socks5h` option combines SOCKS5 with domain resolution, which can be useful in specific scenarios.

## Conclusion

Setting up a proxy for Git doesn't have to be daunting, but it does involve configuring different settings in various files. I trust this article has provided you with the guidance you need to smoothly integrate proxies into your Git workflow.

<img src="/post-images/balloons.jpg" width="400" />
