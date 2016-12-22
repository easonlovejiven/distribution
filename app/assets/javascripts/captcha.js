
var countdown = 60;
function settime(val) {
    if (countdown === 0) {
        val.removeAttribute("disabled");
        val.value = "发送验证码";
        countdown = 60;
        return false;
    } else {
        val.setAttribute("disabled", true);
        val.value = "重新发送(" + countdown + ")";
        countdown--;

    }
    setTimeout(function () {
        settime(val);
    }, 1000);
}

// JavaScript Document
function createCode() {
    code = "";
    var codeLength = 4;//验证码的长度
    var checkCode = document.getElementById("yzm");
    checkCode.value = "";
    var selectChar = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
    for (var i = 0; i < codeLength; i++) {
        var charIndex = Math.floor(Math.random() * 64);
        code += selectChar[charIndex];
    }
    if (code.length !== codeLength) {
        createCode();
    }
    checkCode.value = code;
}

function send_msg(val, type) {
    var account = $("#user_account").val();
    if (account === '') {
        hzb.show_error_note('请填手机号!');
        return false;
    }
    reg = /^1[3|4|5|8][0-9]\d{4,8}$/i;
    if (!reg.test(account)) {
        hzb.show_error_note('手机号不正确');
        return false;
    }
    settime(val);
    $.post("/fx/users/send_sms", {account: account, sort: type}, function (data) {
        if (data["recode"] === 0) {
            if (type) {
                hzb.show_error_note('语音正发出请稍等.');
            }
            return true;
        }
        else {
            return false;
        }
    });
}

function GetRTime() {

    $(".lxftime").each(function () {

        var lxfday = $(this).attr("lxfday");//用来判断是否显示天数的变量
        var endtime = new Date($(this).attr("endtime")).getTime();//取结束日期(毫秒值)
        var nowtime = new Date().getTime();        //今天的日期(毫秒值)
        var youtime = endtime - nowtime; //还有多久(毫秒值)
        var seconds = youtime / 1000;
        var minutes = Math.floor(seconds / 60);
        var hours = Math.floor(minutes / 60);
        var days = Math.floor(hours / 24);
        var CDay = days;
        var CHour = hours % 24;
        var CMinute = minutes % 60;
        var CSecond = Math.floor(seconds % 60);//"%"是取余运算，可以理解为60进一后取余数，然后只要余数。
        if (endtime <= nowtime) {

            $(this).html("已经过期") //如果结束日期小于当前日期就提示过期啦
        } else {
            if ($(this).attr("lxfday") == "no") {
                $(this).html("<span>" + CHour + "</span>时<span>" + CMinute + "</span>分<span>" + CSecond + "</span>秒");          //输出没有天数的数据
            } else {
                $(this).html("<span class='day'>" + days + "</span><em>天</em><span class='hour'>" + CHour + "</span><em>时</em><span class='mini'>" + CMinute + "</span><em>分</em><span class='sec'>" + CSecond + "</span><em>秒</em>");          //输出有天数的数据
            }
        }
    });
    setTimeout("GetRTime()", 1000);
}
