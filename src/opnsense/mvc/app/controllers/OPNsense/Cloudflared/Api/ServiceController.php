<?php

namespace OPNsense\Cloudflared\Api;

use OPNsense\Base\ApiMutableServiceControllerBase;
use OPNsense\Core\Backend;

class ServiceController extends ApiMutableServiceControllerBase
{
    protected static $internalServiceClass = 'OPNsense\Cloudflared\Cloudflared';
    protected static $internalServiceEnabled = 'general.enabled';
    protected static $internalServiceTemplate = 'OPNsense/Cloudflared';
    protected static $internalServiceName = 'cloudflared';

    public function installAction()
    {
        $backend = new Backend();
        $response = $backend->configdRun("cloudflared install_binary");
        return array("response" => $response);
    }
}
