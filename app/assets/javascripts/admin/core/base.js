$(function () {
    $('body').delegate('[data-dismiss="rightPanel"]', 'click', function (e) {
        e.preventDefault();
        if ($("#panel-wrapper").is(':hidden')) {
            var redirect_url = $(this).parents('#content').find('form').attr('data-redirect-url');
            if (redirect_url) {
                setLocationHash(redirect_url);
                checkURL(redirect_url);
            }
        } else {
            $('#panel-wrapper').hide();
        }
        return false;
    }).delegate(".batch_delete,.batch_action", "click", function (e) {
        var container = $(this).parents(".jarviswidget");
        var selected_ids = $(".table tbody .check input:checked", container).map(function () {
            return $(this).attr("id")
        }).get();
        if (selected_ids.length == 0) {
            e.preventDefault();
            e.stopImmediatePropagation();
            alert("请选择数据项");
        } else {
            $(this).attr("href", $(this).data("href") + "?ids=" + selected_ids.join(","));
            //$(this).attr("data-target", "rightPanel");
            //$(this).trigger("click");
            e.preventDefault();
            e.stopPropagation();
        }
    }).delegate('a[data-target="rightPanel"]', 'click', function (e) {
        e.preventDefault();
        var modalManager = $("body").data("modalmanager");
        var modals_count = modalManager == undefined ? 0 : modalManager.getOpenModals().length;
//        var modal_ids=modals.map(function(){return $(this).attr("id").replace(/right-panel-(\d+)/,"")})
        if (modals_count == 0) {
            var $modal = $("#right-panel")
        } else if (modals_count < 2) {
            var $modal = $("#right-panel-" + modals_count);
        } else {
            var $modal = $("#right-panel-2");
        }
        $('body').modalmanager('loading');
        var href = $(this).attr('href');
        if (href.match(/^#/)) {
            $modal.modal('loading');
            setTimeout(function () {
                $modal.html($(href).show()).modal("show")
            }, 1000);
        } else if (href.match(/\.jpg|\.gif|\.jpg|\.png/)) {
            $modal.html("<img src='" + href + "' style='max-width: 700px'/>");
            $modal.modal();
        } else {
            setTimeout(function () {
                $modal.load(href, '', function () {
                    $modal.modal();
                });
            }, 1000);
        }
//        (href != '#') && $('#right-panel').html('<div class="ajax-loading" style="text-align: center; margin-top: 40px;"><img src="<%=asset_path("admin/icon/ajax-loader.gif")%>" width="50" height="50" /></div>').load(href).parent("#panel-wrapper").show();
        return false;
    })
})
window.App = {
    visitor: {},
    url: {},
    redirect: function (url, msg, delay) {
        setTimeout(function () {
            window.location = url;
        }, delay);
        if (msg) {
            App.show_notify_bar(msg, 'info', delay);
        }
    },
    show_error_note: function (msg, delay) {
        if (!delay) {
            delay = 4000;
        }
        App.show_notify_bar(msg, 'error', delay);
    },
    show_ok_note: function (msg, delay) {
        if (!delay) {
            delay = 2000;
        }
        App.show_notify_bar(msg, 'success', delay);
    },
    show_notice_note: function (msg, delay) {
        if (!delay) {
            delay = 3000;
        }
        App.show_notify_bar(msg, 'info', delay);
    },
    show_notify_bar: function (msg, type, delay) {
        Lobibox.notify(type, {
            size: 'mini',
            rounded: true,
            position: 'center top',
            delay: delay,
            icon: false,
            delayIndicator: false,
            msg: msg
        });
    },
    message_ajax: function () {
        $.ajax({
            url: _G_notice_url,
            data: _G_notice_url_params,
            dataType: 'jsonp',
            success: function (data) {
                if (data.notification_count != 0) {
                    $("#notification_count").text(data.notification_count).show();
                } else {
                    $("#notification_count").hide()
                }
            }
        })
    },
    message_poll: function () {
        window.setInterval(this.message_ajax, 50000)
    },
    data: {},
    init: function () {
        this.configToastr();
        this.bindContacts();
        this.handleGoTop();
        this.editable();
        this.checkAll();
        this.handleDatePickers();
    }, configToastr: function () {
        toastr.options = {
            "closeButton": true,
            "debug": false,
            "positionClass": "toast-top-right",
            "onclick": null,
            "showDuration": "300",
            "hideDuration": "500",
            "timeOut": "3000",
            "extendedTimeOut": "800",
            "showEasing": "swing",
            "hideEasing": "linear",
            "showMethod": "fadeIn",
            "hideMethod": "fadeOut"
        };
    }, guid: function () {
        var d = new Date().getTime();
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = (d + Math.random() * 16) % 16 | 0;
            d = Math.floor(d / 16);
            return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
        });
    }, hasEvents: function ($tag, ev) {
        var flag = true;
        var events = $tag.data('events');
        if (!events || !ev) {
            flag = false
        } else {
            flag = !!events[ev]
        }
        return flag
    }, handleBootstrapSelect: function () {
        $('.bs-select').selectpicker({
            iconBase: 'fa',
            tickIcon: 'fa-check'
        });
    }, bindSelect2: function ($input, url, initData) {
        $input.select2({
            placeholder: "备选供应商",
            multiple: true,
            minimumInputLength: 1,
            maximumInputLength: 10,
            ajax: {
                url: url,
                dataType: 'json',
                delay: 200,
                data: function (params) {
                    return {
                        name: params.trim(),
                        page: params.page
                    };
                },
                results: function (data, page) {
                    var items = $.map(data.items, function (item) {
                        return {id: item.id, text: item.name}
                    });
                    return {
                        results: items
                    };
                },
                cache: true
            },
            escapeMarkup: function (markup) {
                return markup;
            },
            templateResult: function (item) {
                return item.text;
            },
            templateSelection: function (item) {
                return "<span>" + item.text + "</span><span>";
            }
        });
        if (initData) {
            $input.select2('data', initData)
        }
    }, handleDatePickers: function ($input, startDate) {
        if ($input === false || startDate === false) {
            startDate = false;
            today = new Date(2012, 1, 6);
        } else {
            var today = startDate || new Date();
        }
        $input = $input || $('.hasDatepicker');
        $input.datepicker({
            todayHighlight: true,
            format: 'yyyy-mm-dd',
            startDate: today,
            autoclose: true
        });
    }, handleDateTimePickers: function ($input) {
        $input = $input || $(".hasDatetimepicker");
        var today = new Date();
        //var endDay = new Date();
        //endDay.setDate(endDay.getDate() + 100);
        //endDay.setHours(endDay.getHours());
        $input.datetimepicker({
            format: 'yyyy-mm-dd hh:ii',
            autoclose: true,
            todayBtn: true,
            startDate: today,
            todayHighlight: true,
            fontAwesome: 'fa',
            zIndex: 102
        })
    }, handleUniform: function () {
        var test = $("input[type=checkbox]:not(.toggle, .make-switch), input[type=radio]:not(.toggle, .star, .make-switch)");
        if (test.size() > 0) {
            test.each(function () {
                if ($(this).parents(".checker").size() == 0) {
                    $(this).show();
                    $(this).uniform();
                }
            });
        }
    }, handleValidation: function ($form, rules, messages, addValidateFun) {
        if (typeof rules == 'function') {
            addValidateFun = rules;
            rules = {}
        } else if (typeof messages == 'function') {
            addValidateFun = rules;
            messages = {}
        }
        $form.validate({
            errorElement: 'span',
            errorClass: 'help-block',
            focusInvalid: false,
            ignore: "ignore",
            rules: rules,
            messages: messages,
            invalidHandler: function (event, validator) {
                var errEl = validator.errorList[0];
                if (errEl) {
                    App.scrollTo($(errEl.element), -200);
                }
                if (addValidateFun) {
                    addValidateFun(validator.currentForm)
                }
            }, errorPlacement: function (error, element) {
                if (element.parent(".input-group").size() > 0) {
                    error.insertAfter(element.parents(".input-group"));
                } else if (element.is('select')) {
                    error.appendTo(element.parent());
                } else if (element.is(":radio") || element.is(":checkbox")) {

                } else {
                    error.insertAfter(element);
                }
            }, highlight: function (element) {
                $(element).closest('.form-group').addClass('has-error');
            }, unhighlight: function (element) {
                $(element).closest('.form-group').removeClass('has-error');
                $($(element).attr("name") + "-error").remove();
            }, success: function (label) {
                label.closest('.form-group').removeClass('has-error');
            }, submitHandler: function (form) {
                var $form = $('form');
                if (addValidateFun && !addValidateFun(form)) {
                    $form.submit(false)
                } else {
                    var remote = $form.data('remote') || $form.attr('remote');
                    if (remote) {
                        $(form).ajaxSubmit();
                    } else {
                        $form.get(0).submit()
                    }
                }
            }
        });
    }, showFlashMessage: function (msg, type) {
        var map = {success: "alert-success", error: "alert-danger", warning: "alert-warning", notice: "alert-info"};
        $('#flash_message').remove();
        $("body").append("<div id='flash_message'></div>");
        $('#flash_message').html("<div class='alert  " + map[type] + "'>" + msg + "</div>")
            .show().delay(2000).fadeOut(2000);
    }, editableField: function ($field, type) {
        var validateFun = function (value) {
            if ($.trim(value) == '') return '此项不能为空！';
            if ((type == 'number') && (/\D/.test(value))) return '请输入非负整数字！';
        };
        var isReload = !!($field.attr('data-reload'));
        $field.editable({
            emptytext: '无',
            inputclass: 'form-control',
            validate: validateFun,
            success: function (data, config) {
                if (data.success) {
                    window.toastr['success'](data.msg, '成功:');
                    if (isReload) {
                        window.location.reload();
                    }
                } else {
                    window.toastr['warning'](data.msg, '失败:');
                }
            }, error: function (data) {
                return false;
            }
        });
    }, scrollTo: function (el, offeset) {
        var pos = (el && el.size() > 0) ? el.offset().top : 0;
        if (el) {
            if ($('body').hasClass('page-header-fixed')) {
                pos = pos - $('.page-header').height();
            }
            pos = pos + (offeset ? offeset : -1 * el.height());
        }
        jQuery('html,body').animate({
            scrollTop: pos
        }, 'slow');
    }, handleSidebarMenu: function () {
        var $this = this;
        jQuery('.page-sidebar').on('click', 'li > a', function (e) {
            if ($(this).next().hasClass('sub-menu') == false) {
                if ($('.btn-navbar').hasClass('collapsed') == false) {
                    $('.btn-navbar').click();
                }
                return;
            }
            if ($(this).next().hasClass('sub-menu always-open')) {
                return;
            }
            var parent = $(this).parent().parent();
            var the = $(this);
            var menu = $('.page-sidebar-menu');
            var sub = jQuery(this).next();

            var autoScroll = menu.data("auto-scroll") ? menu.data("auto-scroll") : true;
            var slideSpeed = menu.data("slide-speed") ? parseInt(menu.data("slide-speed")) : 200;

            parent.children('li.open').children('a').children('.arrow').removeClass('open');
            parent.children('li.open').children('.sub-menu:not(.always-open)').slideUp(200);
            parent.children('li.open').removeClass('open');

            var slideOffeset = -200;

            if (sub.is(":visible")) {
                jQuery('.arrow', jQuery(this)).removeClass("open");
                jQuery(this).parent().removeClass("open");
                sub.slideUp(slideSpeed, function () {
                    if (autoScroll == true && $('body').hasClass('page-sidebar-closed') == false) {
                        if ($('body').hasClass('page-sidebar-fixed')) {
                            menu.slimScroll({'scrollTo': (the.position()).top});
                        } else {
                            $this.scrollTo(the, slideOffeset);
                        }
                    }
                    $this.handleSidebarAndContentHeight();
                });
            } else {
                jQuery('.arrow', jQuery(this)).addClass("open");
                jQuery(this).parent().addClass("open");
                sub.slideDown(slideSpeed, function () {
                    if (autoScroll == true && $('body').hasClass('page-sidebar-closed') == false) {
                        if ($('body').hasClass('page-sidebar-fixed')) {
                            menu.slimScroll({'scrollTo': (the.position()).top});
                        } else {
                            $this.scrollTo(the, slideOffeset);
                        }
                    }
                    $this.handleSidebarAndContentHeight();
                });
            }
            e.preventDefault();
        });
    }, handleSidebarAndContentHeight: function () {
        var $this = this;
        var content = $('.page-content');
        var sidebar = $('.page-sidebar');
        var body = $('body');
        var height;

        if (body.hasClass("page-footer-fixed") === true && body.hasClass("page-sidebar-fixed") === false) {
            var available_height = $(window).height() - $('.page-footer').outerHeight() - $('.page-header').outerHeight();
            if (content.height() < available_height) {
                content.attr('style', 'min-height:' + available_height + 'px');
            }
        } else {
            if (body.hasClass('page-sidebar-fixed')) {
                height = $this.calculateFixedSidebarViewportHeight();
                if (body.hasClass('page-footer-fixed') === false) {
                    height = height - $('.page-footer').outerHeight();
                }
            } else {
                height = sidebar.height() + 20;
                var headerHeight = $('.page-header').outerHeight();
                var footerHeight = $('.page-footer').outerHeight();
                if ($(window).width() > 1024 && (height + headerHeight + footerHeight) < $(window).height()) {
                    height = $(window).height() - headerHeight - footerHeight;
                }
            }
            if (height >= content.height()) {
                content.attr('style', 'min-height:' + height + 'px');
            }
        }
    }, calculateFixedSidebarViewportHeight: function () {
        var sidebarHeight = $(window).height() - $('.page-header').outerHeight();
        if ($('body').hasClass("page-footer-fixed")) {
            sidebarHeight = sidebarHeight - $('.page-footer').outerHeight();
        }
        return sidebarHeight;
    }, bindContacts: function () {
        jQuery(function () {
            $(".right_contacts ul>li:has(div.drawer)").hover(function () {
                $(this).children(".drawer").stop(true, true).animate({"right": "0"}, 360);
            }, function () {
                $(this).children(".drawer").stop(true, true).animate({"right": "-201"}, 360);
            });
        });
    }, handleGoTop: function () {
        jQuery('.page-footer').on('click', '.go-top', function (e) {
            App.scrollTo();
            e.preventDefault();
        });
    }, handleRjsCb: function ($eml, validate) {
        // 按钮绑定的rjs 和 form 绑定的Rjs
        validate = !(validate == false);
        if (validate && $eml.is('form')) {
            App.handleValidation($eml);
        }
        $eml.on('ajax:success', function (event, data) {
            if (data.success) {
                toastr.success(data.msg, '成功:');
                if ($eml.is('form')) {
                    $eml.get(0).reset();
                }
                if ($eml.attr('data-reload')) {
                    window.location.reload();
                } else if (data.location) {
                    window.location.href = data.location;
                }
            } else {
                if (data.errors) {
                    data.msg += App.flattenMsg(data.errors)
                }
                toastr.warning(data.msg, '失败:');
            }
        }).on("ajax:error", function (event, data) {
            data = $.parseJSON(data.responseText);
            if (data) {
                if (data.success) {
                    toastr.success(data.msg, '成功:');
                    if ($eml.is('form')) {
                        $eml.get(0).reset();
                    }
                    if (data.location) {
                        window.location.href = data.location;
                    } else if ($eml.attr('data-reload')) {
                        window.location.reload();
                    }
                } else {
                    if (data.errors) {
                        data.msg += App.flattenMsg(data.errors)
                    }
                    toastr.warning(data.msg, '失败:');
                }
            } else {
                toastr.error('未知错误！', '错误:');
            }
        });
        return $eml;
    }, flattenMsg: function (obj) {
        var type = $.type(obj);
        if (type == 'array') {
            return obj[0];
        } else if (type == 'object') {
            var msg = '<br />';
            for (var key in obj) {
                msg += obj[key];
                break;
            }
            return msg
        } else if (type == 'string') {
            return obj;
        } else {
            return '';
        }
    }, initDatepikerData: function () {
        if (typeof $.fn.datepicker == 'function') {
            $.fn.datepicker.dates['en'] = {
                days: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"],
                daysShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六", "周日"],
                daysMin: ["日", "一", "二", "三", "四", "五", "六", "日"],
                months: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
                monthsShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
                today: "今日"
            };
        }
    }, initMultiSelect2: function ($selector) {
        $($selector).select2().on("change", function () {
        })
    }, editable: function () {
        $(".editable").editable({
            ajaxOptions: {type: 'put'},
            params: function (params) {
                alert(params)
                //originally params contain pk, name and value
                params.a = 1;
                return params;
            }
        })
    }, checkAll: function () {
        $('body').delegate('#checkall input', 'click', function (e) {
            var container = $(this).parents(".table");
            $("tbody .check input", container).prop('checked', $(this).prop("checked"));
        })
    }
};

function highlight(id, color) {
    var id = arguments[0] ? arguments[0] : '';
    //接受参数,默认为红色
    var color = arguments[1] ? arguments[1] : '#FFFFE0';
    //验证参数是否为空
    if (id) {
        var target = $('#' + id);
        //验证元素是否为空
        if (target.length > 0) {
            var originalColor = target.css('backgroundColor');
            var changeColor = color;
            target.css({backgroundColor: changeColor, opacity: 0}).animate({
                opacity: 3
            }, 500, function () {
                $(this).css({backgroundColor: originalColor, opacity: 1})
            });
        } else {
            alert('对象为空,请检查元素是否存在');
        }
    } else {
        alert('id参数不能为空');
    }
}

function copyToClipboard(txt) {
    if (window.clipboardData) {
        window.clipboardData.clearData();
        window.clipboardData.setData("Text", txt);
    } else if (window.netscape) {
        try {
            netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
        } catch (e) {
            alert("被浏览器拒绝！\n请在浏览器地址栏输入'about:config'并回车\n然后将'signed.applets.codebase_principal_support'设置为'true'");
            return;
        }

        var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
        if (!clip) return;
        var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
        if (!trans) return;
        trans.addDataFlavor('text/unicode');
        var str = new Object();
        var len = new Object();
        var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
        var copytext = txt;
        str.data = copytext;
        trans.setTransferData("text/unicode", str, copytext.length * 2);
        var clipid = Components.interfaces.nsIClipboard;
        if (!clip) return false;
        clip.setData(trans, null, clipid.kGlobalClipboard);
    } else {
        alert("浏览器不支持复制到剪贴板");
    }
}
$(function () {
    App.init();
});
