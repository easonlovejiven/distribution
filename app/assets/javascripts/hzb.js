var hzb = {
    visitor: {},
    url: {},
    redirect: function (url, msg, delay) {
        setTimeout(function () {
            window.location = url;
        }, delay);
        if (msg) {
            hzb.show_notify_bar(msg, 'info', delay);
        }
    },
    redirect_to: function (url, msg, delay) {
        setTimeout(function () {
            window.location = url;
        }, delay);
        if (msg) {
            hzb.show_verify_ok();
        }
    },
    show_error_note: function (msg, delay) {
        if (!delay) {
            delay = 3000;
        }
        hzb.show_notify_bar(msg, 'error', delay);
    },
    show_ok_note: function (msg, delay) {
        if (!delay) {
            delay = 2000;
        }
        hzb.show_notify_bar(msg, 'success', delay);
    },
    show_notice_note: function (msg, delay) {
        if (!delay) {
            delay = 3000;
        }
        hzb.show_notify_bar(msg, 'info', delay);
    },
    show_notify_bar: function (msg, type, delay) {
        if (window.plus) {
            plus.nativeUI.toast(msg);
            setTimeout(function () {
                first = null;
            }, delay);
        }
        else {
            Lobibox.notify(type, {
                size: 'mini',
                rounded: true,
                position: 'center top',
                delay: delay,
                icon: false,
                delayIndicator: false,
                msg: msg
            });
        }
    },
    show_verify_ok: function (msg) {
        bg(true);
        tk(true);
        setTimeout(function () {
            bg(false);
            tk(false);
        }, 2000);
    },
    show_verify_note: function (msg) {
        bg(true);
        out(true);
    },
    show_verify_error: function (msg) {
        bg(true);
        er(true, msg);
        setTimeout(function () {
            bg(false);
            er(false);
        }, 2000);
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
                    $("#notification_count").hide();
                }
            }
        });
    },
    message_poll: function () {
        window.setInterval(this.message_ajax, 50000);
    }

};

var Local = window.Local || {};

Local.storageUnits = ['B', 'KB', 'MB', 'GB', 'TB'];
Local.storageHex = 1024;

Local.format = function (num, hex, units, dec, forTable) {
    num = num || 0;
    dec = dec || 0;
    forTable = forTable || false;
    var level = 0;

    // 详细报表中表格数据的最小单位为 KB 和 万次
    if (forTable) {
        num /= hex;
        level++;
    }
    while (num >= hex) {
        num /= hex;
        level++;
    }

    if (level === 0) {
        dec = 0;
    }

    return {
        'base': num.toFixed(dec),
        'unit': units[level],
        'format': function (sep) {
            sep = sep || '';
            return this.base + sep + this.unit;
        }
    };
};

Local.IE = (function () {
    var v = 4,
            div = document.createElement('div'),
            all = div.getElementsByTagName('i');
    while (
            div.innerHTML = '<!--[if gt IE ' + v + ']><i></i><![endif]-->',
            all[0]
            ) {
        v++;
    }
    return v > 4 ? v : false;
}());

Local.uploaderRuntime = Local.IE && Local.IE < 10 ? 'flash' : 'html5,flash';
console.log(Local.uploaderRuntime);


hzb.add_demand_line = function () {
    $("#add_line").click(function () {
        temp_tr = $("#temp-tr").clone();
        temp_tr.show();
        temp_tr.attr("id", "");
        $("table").append(temp_tr);
    });
};
hzb.edit_table = function () {
    $("#edit_form").click(function () {
        $("#tianjia").show();
        $("#submit_form").removeAttr("disabled");
        $(".inp_first").each(function (index, element) {
            $(this).removeAttr("disabled");
        });
    });
};

//上传
hzb.plupload = function (url, upToken, pic_id) {
    var upload_progress = pic_id + "_upload_progress";
    var browse_button = pic_id + "_pickfiles";
    console.log(browse_button)
    var uploader = new plupload.Uploader({
        runtimes: 'html5,flash',
        browse_button: browse_button,
        //container: 'container',
        filters: {
            mime_types: [//只允许上传图片
                {title: "Image files", extensions: "jpg,gif,png,JPEG,PNG,GIF"}
            ],
            max_file_size: '5mb'  //最大只能上传5M的文件
                    //prevent_duplicates: true //不允许选取重复文件
        },
        url: url,
        flash_swf_url: '/assets/Moxie.swf',
        silverlight_xap_url: '/assets/Moxie.xap',
        multipart_params: {
            "token": upToken
        }
    });

    var count = uploader.files.length;

    uploader.bind('Init', function (up, params) {
        //显示当前上传方式，调试用
        console.log('Current runtime:  ' + params.runtime);
    });
    uploader.init();
    uploader.bind('FilesAdded', function (up, files) {
        $.each(files, function (i, file) {
            if (up.files.length > 9 && type === 'case') {
                alert('图片数量不能大于9张');
                return;
            }
            var progress = new FileProgress(file, upload_progress);
            progress.setStatus("等待...");
            progress.toggleCancel(true, uploader);
            up.start();
        });
        up.refresh(); // Reposition Flash/Silverlight
    });
    uploader.bind('BeforeUpload', function (up, file) {
        var progress = new FileProgress(file, upload_progress);
        var point = file.name.lastIndexOf(".");
        var type = file.name.substr(point);
        var timestamp = (new Date()).valueOf();
        var file_name = timestamp + Math.random();
        up.settings.multipart_params.key = file_name + type;
    });
    uploader.bind('UploadProgress', function (up, file) {
        var progress = new FileProgress(file, upload_progress);
        progress.setProgress(file.percent + "%", up.total.bytesPerSec);
        progress.setStatus("上传中...", true);
    });
    uploader.bind('Error', function (up, err) {
        var file = err.file;
        var errTip = '';
        if (file) {
            var progress = new FileProgress(file, upload_progress);
            progress.setError();
            switch (err.code) {
                case plupload.FAILED:
                    errTip = '上传失败';
                    break;
                case plupload.FILE_SIZE_ERROR:
                    errTip = '文件不能超过3M';
                    break;
                case plupload.FILE_EXTENSION_ERROR:
                    errTip = '非法的文件类型';
                    break;
                case plupload.FILE_DUPLICATE_ERROR:
                    errTip = '文件已存在';
                    break;
                case plupload.HTTP_ERROR:
                    switch (err.status) {
                        case 400:
                            errTip = "请求参数错误";
                            break;
                        case 401:
                            errTip = "认证授权失败";
                            break;
                        case 405:
                            errTip = "请求方式错误，非预期的请求方式";
                            break;
                        case 579:
                            errTip = "文件上传成功，但是回调（callback app-server）失败";
                            break;
                        case 599:
                            errTip = "服务端操作失败";
                            break;
                        case 614:
                            errTip = "文件已存在";
                            break;
                        case 631:
                            errTip = "指定的存储空间（Bucket）不存在";
                            break;
                        default:
                            errTip = "其他HTTP_ERROR";
                            break;
                    }
                    break;
                case plupload.SECURITY_ERROR:
                    errTip = '安全错误';
                    break;
                case plupload.GENERIC_ERROR:
                    errTip = '通用错误';
                    break;
                case plupload.IO_ERROR:
                    errTip = '上传失败。请稍后重试';
                    break;
                case plupload.INIT_ERROR:
                    errTip = '配置错误';
                    uploader.destroy();
                    break;
                default:
                    errTip = err.message + err.details;
                    break;
            }
            alert(errTip);
            progress.setStatus(errTip);
            progress.setCancelled();
        }
        up.refresh(); // Reposition Flash/Silverlight
    });
    uploader.bind('FileUploaded', function (up, file, info) {
        var progress = new FileProgress(file, upload_progress);
        progress.setComplete();
        // progress.setStatus("上传完成");
        progress.toggleCancel(false);
        var res = $.parseJSON(info.response);
        if (res.key === 500) {
            alert(res.error_msg);
            return false;
        }
        $("#" + pic_id + "_value").val(res.key);
        $.get("/admin/assets/updone.json", {'key': res.key}, function (data) {
            $("#" + pic_id + "_preview").attr("src", data.file_url);
        });
    });
};
