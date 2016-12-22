(function ($) {
    $.extend({
        timeParse: function (a) {
            a = Date.parse(a);
            if (!a)return "";
            var b = (+new Date - a) / 1E3;
            if (b < 60)return "\u521a\u521a";
            if (b < 3600)return Math.floor(b / 60) + "\u5206\u949f\u524d";
            if (b < 86400)return Math.floor(b / 3600) + "\u5c0f\u65f6\u524d";
            if (b < 1296E3)return Math.floor(b / 86400) + "\u5929\u524d";
            a = new Date(a);
            return a.getFullYear() + "/" + d.pad(a.getMonth() + 1, 2) + "/" + d.pad(a.getDate(), 2) + " " + d.pad(a.getHours(), 2) + ":" + d.pad(a.getMinutes(), 2)
        }, clearTimer: function (a) {
            clearInterval(a);
            clearTimeout(a);
            return null
        }, rnd: function (a, b) {
            return Math.floor((b - a + 1) * Math.random() + a)
        }, isString: function (a) {
            return typeof a === "string"
        }, isNotEmptyString: function (a) {
            return d.isString(a) &&
                a !== ""
        }, getByteLen: function (a) {
            if (!a)return 0;
            var b = a.match(/[^\x00-\xff]/ig);
            return a.length + (b == null ? 0 : b.length)
        }, getChsLen: function (a) {
            if (!a)return 0;
            var b = a.match(/[^\x00-\xff]/ig);
            return a.length * 0.5 + (b == null ? 0 : b.length * 0.5)
        }, substr: function (a, b) {
            if (!a)return "";
            for (var d = /[^\x00-\xff]/ig, j = 0, m = "", o = 0; o < a.length; o++) {
                var n = a.charAt(o), j = n.match(d) ? j + 2 : j + 1;
                if (j > b)break;
                m = m + n
            }
            return m
        }, getUrlPath: function (a) {
            return a.replace(/\?.+$/, "");
        }, getUrlParams: function (url) {
            url = url.replace(/^.+\?/, "");
            var results = {};
            var sPageURL = decodeURIComponent(url),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;

            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[1]) {
                    results[sParameterName[0]] = sParameterName[1]
                }
            }
            return results;
        }, replaceUrlParam: function (objs) {
            var url = $.getUrlPath(window.location.href);
            var params = $.getUrlParams(window.location.href), search = '?';
            $.each(objs, function (k, v) {
                params[k] = v;
            });
            $.each(params, function (k, v) {
                search += k + '=' + v + '&'
            });
            return url + search;
        },
        isEmail: function (a) {
            return /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(a)
        }
    });

    $.fn.authUserActions = function (options) {
        function authAndRun(fu, opts) {
            if ((typeof fu) == "function") {
                fu(opts);
            }
        }

        return this.each(function () {
            var $this = $(this);
            var defaults = {
                current_user: $.fn.authUserActions.current_user,
                ownerId: 'ownerid',
                loginAction: null,
                ownerAction: null,
                loginNoOwnerAction: null
            };
            var opts = $.extend(defaults, options || {});
            if ($this.data(opts.ownerId) == opts.current_user.id) {
                $this.removeClass("hidden");
                authAndRun(opts.ownerAction, opts)
            } else {
                authAndRun(opts.loginNoOwnerAction, opts)
            }
            authAndRun(opts.loginAction, opts)
        });
    };
    $.fn.authUserActions.current_user = {};

    $.fn.serializeObject = function () {
        var o = {};
        var a = this.serializeArray();
        $.each(a, function () {
            if (o[this.name] !== undefined) {
                if (!o[this.name].push) {
                    o[this.name] = [o[this.name]];
                }
                o[this.name].push(this.value || '');
            } else {
                o[this.name] = this.value || '';
            }
        });
        return o;
    };

    $.fn.textCounter = function () {
        if (!this.length)return this;
        this.each(function () {
            var a = $(this), c = parseInt(a.attr("maxlen")), f, g, j;
            if (!(isNaN(c) || c <= 0)) {
                var c = Math.ceil(c), m = a.data("form-info-id");
                if (!m) {
                    f = $('<div class="form-tips-info" style="width:60px;text-align:center"><span></span>/' + c + "</div>").appendTo("body").data("form-info-id", 1);
                    g = f.find("span");
                    a.on("focus blur", function (m) {
                        clearInterval(j);
                        if (m.type == "focus") {
                            var m = f.outerHeight(), n = f.outerWidth(), l = a.offset(), p = a.outerWidth();
                            //d.scrollLeft();
                            //d.scrollTop();
                            f.css({position: "absolute", left: l.left + p - n, top: l.top + m * 2}).show();
                            j = setInterval(function () {
                                var d = a.val(), d = Math.ceil(d.length);
                                g.text(d);
                                d > c ? f.addClass("form-tips-error") : f.removeClass("form-tips-error")
                            }, 20)
                        } else f.hide()
                    })
                }
            }
        });
        return this
    };

    // 配置插件
    $.validator.setDefaults({
        highlight: function (element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function (element) {
            $(element).closest('.form-group').removeClass('has-error');
            $(element).parent().find(".error-help-block").remove();
        },
        errorElement: 'span',
        errorClass: 'help-block error-help-block',
        errorPlacement: function (error, element) {
            $(element).parent().find(".error-help-block").remove();
            if (element.parent('.input-group').length) {
                error.insertAfter(element.parent());
            } else {
                error.insertAfter(element);
            }
        }
    });
    $.extend($.validator.messages, {
        required: "不能为空！",
        remote: "请修正此栏位",
        email: "请输入有效的邮箱地址！",
        url: "请输入有效的网址！",
        date: "请输入有效的日期！",
        dateISO: "请输入有效的日期 (YYYY-MM-DD)！",
        number: "请输入正确的数值！",
        digits: "只可输入数字！",
        creditcard: "请输入有效的信用卡号码！",
        equalTo: "请重複输入一次！",
        extension: "请输入有效的后缀！",
        maxlength: $.validator.format("最多 {0} 个字！"),
        minlength: $.validator.format("最少 {0} 个字！"),
        rangelength: $.validator.format("请输入长度为 {0} 至 {1} 之间的字串！"),
        range: $.validator.format("请输入 {0} 至 {1} 之间的数值！"),
        max: $.validator.format("请输入不大于 {0} 的数值！"),
        min: $.validator.format("请输入不小于 {0} 的数值！")
    });
    $(document).ajaxError(function (e, xhr, settings) {
        if (xhr.status == 401) {
            var login_dialog = $("#user_sign_in");
            if (login_dialog.length > 0) {
                App.showFlashMessage("用户名密码错误", "error");
            } else {
                window.location.href = "/users/sign_in";
            }
        }
    });
})(jQuery);

