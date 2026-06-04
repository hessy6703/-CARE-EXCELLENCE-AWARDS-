<?php
/**
 * CEAMS - Home Controller
 */

namespace App\Controllers;

class HomeController extends BaseController
{
    /**
     * Show home page
     */
    public function index()
    {
        if ($this->auth) {
            $this->redirect('/dashboard');
        }
        $this->view('home');
    }
}
