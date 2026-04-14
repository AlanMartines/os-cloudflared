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
        if ($this->request->isPost()) {
            $backend = new Backend();
            $response = $backend->configdRun("cloudflared install_binary");
            if ($response === null) {
                return ['response' => 'ERROR: configd did not respond. Run "service configd restart" on OPNsense.'];
            }
            $response = trim($response);
            if ($response === '' || $response === 'FAILED') {
                return ['response' => 'ERROR: Action not found. Run "service configd restart" on OPNsense to reload actions.'];
            }
            return ['response' => $response];
        }
        return ['response' => 'error'];
    }
}
