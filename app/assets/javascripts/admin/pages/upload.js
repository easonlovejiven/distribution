$.fn.qiniuUpload = function (options) {
    var progress_container = $(this).attr("id").replace("_btn", "") + "_upload_progress";
    var defaults = {
        domain: $('#domain').val(),
        btn_class: $(this).attr("id"),
        container: $(this).attr("id") + "_wrap",
        progress_container: progress_container,
        bucket: "images",
        max_files: 5,
        max_size: "35mb"
    }
    var options = $.extend(defaults, options);
    $("#" + progress_container + " .remove_btn").on("click", function (e, data, status, xhr) {
        $(this).parents(".progressContainer").attr("data-destroy", 1).html("");
        return false;
    })
    var uploader = Qiniu().uploader({
        runtimes: 'html5,flash,html4',
        browse_button: options.btn_class,
        container: options.container,
        drop_element: options.container,
        max_file_size: options.max_size,
        flash_swf_url: "/Moxie.swf",
        dragdrop: true,
        chunk_size: '4mb',
        uptoken_url: "/uploads/uptoken",
        domain: options.domain,
        multi_selection: options.max_files > 1,
        filters: [
            {title: "Image files", extensions: "jpg,png,jpeg"}
        ],
        auto_start: true,
        init: {
            'FilesAdded': function (up, files) {
                var max_files = options.max_files;

                plupload.each(files, function (file) {
                    if (up.files.length > max_files) {
                        up.removeFile(file);
                    } else {
                        var progress = new FileProgress(file, options.progress_container);
                        progress.setStatus("loading");
                    }
                });
                if (max_files <= 1) {
                    $("#" + progress_container + " li:first").remove();
                }
                if (up.files.length >= max_files) {
                    App.showFlashMessage("最多支持" + max_files + "个图片上传", "notice");
                }
            },
            'BeforeUpload': function (up, file) {
            },
            'UploadProgress': function (up, file) {
                var progress = new FileProgress(file, options.progress_container);
                var chunk_size = plupload.parseSize(this.getOption('chunk_size'));
                progress.setProgress(file.percent + "%", up.total.bytesPerSec, chunk_size);
            },
            'UploadComplete': function (up, files) {
                plupload.each(files, function (file) {
                    var progress = new FileProgress(file, options.progress_container);
                    $('.remove_btn', progress.fileProgressWrapper).on("click", function (e, data, status, xhr) {
                        up.removeFile(progress.file);
                        return false;
                    })
                })
            },
            'FileUploaded': function (up, file, info) {
                var data = $.parseJSON(info);
                var key = data.key.replace("images/", "");
                $.post("/uploads.json", {
                    "upload[file_key]": key,
                    'upload[file_name]': file.name,
                    'upload[file_type]': file.type,
                    'upload[file_size]': file.size || 0
                }, function (data) {
                    var res = $.parseJSON(info);
                    var domain = "http://" + up.getOption('domain');
                    //var url = domain + encodeURI(res.key) + "-tiny";
                    var progress = new FileProgress(file, options.progress_container);
                    progress.setComplete(up, info, data);
                    $("#" + file.id).attr("data-upload-key", key);
                })
            },
            'FilesRemoved': function (up, files) {
                plupload.each(files, function (file) {
                    $("#" + file.id).attr("data-destroy", 1).html("");
                })
            },
            'Error': function (up, err, errTip) {
//                    var progress = new FileProgress(err.file, 'fsUploadProgress');
//                    progress.setError();
//                    progress.setStatus(errTip);
                if (err.code == -600) {
                    bootbox.alert("图片不得大于" + options.max_size + ",上传失败!");
                } else {
                    bootbox.alert("上传失败!");
                }
                up.refresh();
            },
            'Key': function (up, file) {
                return options.bucket + "/" + App.guid() + ".jpg";
            }
        }
    });
}
