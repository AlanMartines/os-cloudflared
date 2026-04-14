{#
 # Copyright (C) 2026 Alan Martines <alancpmartines@hotmail.com>
 # All rights reserved.
 #}

<script>
    $( document ).ready(function() {
        var data_get_map = {'frm_general':"/api/cloudflared/settings/get"};
        mapDataToFormUI(data_get_map).done(function(data){
            $('.selectpicker').selectpicker('refresh');
        });

        // link save button
        $("#saveBtn").click(function(){
            saveFormToEndpoint("/api/cloudflared/settings/set", 'frm_general', function(){
                ajaxCall("/api/cloudflared/service/reconfigure", {}, function(data, status) {
                    updateServiceStatus();
                });
            }, false);
        });

        // link install button
        $("#installBtn").click(function(){
            $("#installBtn").prop('disabled', true);
            $("#installIcon").addClass('fa-spinner fa-spin').removeClass('fa-download');
            ajaxCall("/api/cloudflared/service/install", {}, function(data, status) {
                $("#installBtn").prop('disabled', false);
                $("#installIcon").addClass('fa-download').removeClass('fa-spinner fa-spin');
                if (status === "success" && data.response) {
                    var output = data.response.trim();
                    if (output.indexOf("successful") !== -1) {
                        BootstrapDialog.alert({
                            type: BootstrapDialog.TYPE_SUCCESS,
                            title: "{{ lang._('Install/Update Binary') }}",
                            message: output
                        });
                    } else {
                        BootstrapDialog.alert({
                            type: BootstrapDialog.TYPE_DANGER,
                            title: "{{ lang._('Install/Update Binary') }}",
                            message: output
                        });
                    }
                }
            });
        });

        updateServiceStatus();
    });

    function updateServiceStatus() {
        updateServiceControlUI('cloudflared');
    }
</script>

<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#general">{{ lang._('General Settings') }}</a></li>
</ul>

<div class="tab-content content-box">
    <div id="general" class="tab-pane fade in active">
        <div class="content-box-main">
            {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_general'])}}
            <div class="col-md-12">
                <hr />
                <button class="btn btn-primary" id="saveBtn" type="button"><b>{{ lang._('Apply') }}</b> <i id="saveProgress" class=""></i></button>
                <button class="btn btn-default" id="installBtn" type="button"><i id="installIcon" class="fa fa-download"></i> <b>{{ lang._('Install/Update Binary') }}</b></button>
            </div>
        </div>
    </div>
</div>

{{ partial("layout_partials/base_service_control",['service':'cloudflared']) }}
