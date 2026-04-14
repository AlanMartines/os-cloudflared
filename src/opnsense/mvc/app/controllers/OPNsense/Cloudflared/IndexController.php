<?php

namespace OPNsense\Cloudflared;

use OPNsense\Base\IndexController;

class IndexController extends IndexController
{
    public function indexAction()
    {
        $this->view->generalForm = $this->getForm("general");
        $this->view->pick('OPNsense/Cloudflared/index');
    }
}
